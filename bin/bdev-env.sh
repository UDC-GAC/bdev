#!/bin/bash

export APP_NAME=BDEv
export APP_VERSION=4.1.0-dev

if [[ -z $BDEV_HOME ]]; then
        echo "Error: BDEV_HOME must be set"
	exit -1
fi

export BDEV_START_DATE=$(date +"%d_%m_%Y_%H-%M-%S-%5N")
export BDEV_WEBPAGE="https://bdev.des.udc.es"
export BDEV_DEFAULT_CONF_DIR=$BDEV_HOME/etc
export BDEV_BIN_DIR=$BDEV_HOME/bin
export BDEV_LIB_DIR=$BDEV_HOME/lib
export BDEV_TOOLS_DIR=$BDEV_HOME/tools
export BDEV_HELPERS_DIR=$BDEV_BIN_DIR/helpers
export BENCHMARKS_DIR=$BDEV_HOME/benchmarks
export TEMPLATES_DIR=$BDEV_HOME/templates
export FRAMEWORKS_SRC_DIR=$BDEV_HOME/src
export COMMON_BENCH_DIR=$BENCHMARKS_DIR/common
export COMMON_SRC_DIR=$FRAMEWORKS_SRC_DIR/common
export COMMON_HADOOP_DIR=$FRAMEWORKS_SRC_DIR/common/hadoop
export STORAGE_BACKEND_LIB=$COMMON_SRC_DIR/storage/storage_backend.sh
export CLEANUP_ON_EXIT="false"
export USER=${USER:-$(id -nu)}

# Monitoring tools
export DOOL_VERSION="1.3.8"
export ILO_SCRIPTS_VERSION="6.00.0"
export DOOL_HOME="$BDEV_TOOLS_DIR/dool-$DOOL_VERSION"
export DOOL_COMMAND_NAME="dool"
export RAPL_HOME="$BDEV_BIN_DIR/rapl"
export RAPL_COMMAND_NAME="rapl_monitor"
export ILO_SCRIPTS="$BDEV_TOOLS_DIR/ilo-$ILO_SCRIPTS_VERSION"
export BDWATCHDOG_SRC_DIR="$BDEV_TOOLS_DIR/BDWatchdog"
export BDWATCHDOG_DAEMONS_BIN_DIR="$BDWATCHDOG_SRC_DIR/MetricsFeeder/bin"

if [[ ! -d "$BDEV_BIN_DIR" ]]; then
	echo "Error: bin directory does not exist or is not a directory: $BDEV_BIN_DIR"
	exit
fi

if [[ ! -f "$BDEV_BIN_DIR/functions.sh" ]]; then
	echo "Error: bin/functions.sh not found"
	exit
fi

# Load BDEv functions
. $BDEV_BIN_DIR/functions.sh

if [[ -z $BDEV_CONF_DIR ]]; then
	PRINT_CONF_DIR_WARNING=true
	export BDEV_CONF_DIR=$BDEV_DEFAULT_CONF_DIR
fi

if [[ -z "$BDEV_FRAMEWORKS_DIR" ]]; then
	export BDEV_FRAMEWORKS_DIR=$BDEV_HOME/frameworks
fi

if [[ -z "$BDEV_OUTPUT_DIR" ]]; then
	PRINT_OUTPUT_DIR_WARNING=true
	export BDEV_OUTPUT_DIR="$PWD/${APP_NAME}_${APP_VERSION}_OUTPUT"
else
	export BDEV_OUTPUT_DIR="$BDEV_OUTPUT_DIR/${APP_NAME}_${APP_VERSION}_OUTPUT"
fi

export REPORT_DIR="${BDEV_OUTPUT_DIR}/${APP_NAME}_report_${BDEV_START_DATE}"
export REPORT_FILE=$REPORT_DIR/summary
export REPORT_LOG=$REPORT_DIR/log
export REPORT_GEN_GRAPHS_FILE=$REPORT_DIR/gen_all_plots.sh
REPORT_BIN_DIR=$REPORT_DIR/bin
export REPORT_TOOLS_DIR=$REPORT_DIR/tools
export PLOT_HOME=$REPORT_BIN_DIR/plot
export PLOT_DIR=$REPORT_DIR/plots
export RAPL_PLOT_DIR=$PLOT_DIR/rapl
export OPROFILE_PLOT_DIR=$PLOT_DIR/oprofile
export ILO_PLOT_DIR=$PLOT_DIR/ilo

if [[ ! -d "$REPORT_DIR" ]]; then
	if ! mkdir -p "$REPORT_DIR" ; then
		m_exit "Could not create report directory at $REPORT_DIR"
	fi
fi

m_echo "Running $APP_NAME v$APP_VERSION from BDEV_HOME=$BDEV_HOME"
m_echo "Reporting to $REPORT_DIR"

if [[ "$PRINT_OUTPUT_DIR_WARNING" == "true" ]]; then
	m_warn "BDEV_OUTPUT_DIR not defined, using default directory: $BDEV_OUTPUT_DIR"
fi

if ! is_nfs "$BDEV_OUTPUT_DIR"; then
	m_warn "BDEV_OUTPUT_DIR is not a shared directory mounted using NFS, which will likely cause issues for multi-node executions: $BDEV_OUTPUT_DIR"
fi

if [[ "$PRINT_CONF_DIR_WARNING" == "true" ]]; then
	m_warn "BDEV_CONF_DIR not defined, using default directory: $BDEV_DEFAULT_CONF_DIR"
fi

if [[ ! -d "$BDEV_CONF_DIR" ]]; then
	m_exit "BDEV_CONF_DIR does not exist or is not a directory: $BDEV_CONF_DIR"
fi

if [[ ! -d "$BDEV_FRAMEWORKS_DIR" ]]; then
	m_exit "BDEV_FRAMEWORKS_DIR does not exist or is not a directory: $BDEV_FRAMEWORKS_DIR"
fi

export BDEV_CONF_DIR=$(cd "$BDEV_CONF_DIR" && pwd)
export BDEV_CONF_DIR_ORIG="$BDEV_CONF_DIR"
m_echo "Configuration directory: $BDEV_CONF_DIR"

REQUIRED_FILES=(
    "$BDEV_CONF_DIR/bdev-conf.sh"
    "$BDEV_CONF_DIR/system-conf.sh"
    "$BDEV_CONF_DIR/hdfs.sh"
    "$BDEV_CONF_DIR/yarn.sh"
    "$BDEV_CONF_DIR/mapreduce.sh"
    "$BDEV_CONF_DIR/benchmarks-conf.sh"
    "$BDEV_CONF_DIR/frameworks-conf.sh"
    "$BDEV_CONF_DIR/cluster_sizes.lst"
    "$BDEV_CONF_DIR/benchmarks.lst"
    "$BDEV_CONF_DIR/frameworks.lst"
)

MISSING_FILES=()

for FILE in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$FILE" ]]; then
        MISSING_FILES+=("$FILE")
    fi
done

if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
    m_error "Required configuration files not found:"
    printf '  %s\n' "${MISSING_FILES[@]}"
    m_exit "Missing configuration files at $BDEV_CONF_DIR"
fi

# Load BDEv and system configuration files
. $BDEV_CONF_DIR/bdev-conf.sh
. $BDEV_CONF_DIR/system-conf.sh

# Storage backend
if [[ -z "$STORAGE_BACKEND" ]]; then
	export STORAGE_BACKEND=hdfs
	m_warn "STORAGE_BACKEND is not defined or is empty. Setting it to \"hdfs\""
fi

if [[ "${STORAGE_BACKEND,,}" == "nfs" ]]; then
	if [[ -n "$NFS_MOUNT_POINT" ]]; then
	        m_exit "NFS_MOUNT_POINT is empty"	
	fi
	
	if [[ ! -d "$NFS_MOUNT_POINT" ]]; then
	        m_exit "NFS_MOUNT_POINT does not exist or is not a directory: $NFS_MOUNT_POINT"
	fi
    
	if ! is_nfs "$NFS_MOUNT_POINT"; then
	        m_exit "NFS_MOUNT_POINT is not a shared directory mounted using NFS: $NFS_MOUNT_POINT"
	fi

	export NFS_MOUNT_POINT=$(cd "$NFS_MOUNT_POINT" && pwd)
fi

if [[ -z "${TMP_DIR:-}" ]]; then
	m_warn "TMP_DIR is not defined or is empty. Setting it to /tmp"
	export TMP_DIR=/tmp
fi

# TMP_DIR and LOCAL_DIRS
export TMP_DIR="${TMP_DIR}/${USER}/${APP_NAME}"

if [[ -z "${LOCAL_DIRS:-}" ]]; then
	export LOCAL_DIRS="$TMP_DIR"
	m_warn "LOCAL_DIRS is not defined or is empty. Setting it to $TMP_DIR"
else
	LOCAL_DIRS="${LOCAL_DIRS//,/ }"
	LOCAL_DIRS_NEW=""

	for dir in $LOCAL_DIRS; do
		LOCAL_DIRS_NEW+="${dir}/${USER}/${APP_NAME} "
	done

	export LOCAL_DIRS="${LOCAL_DIRS_NEW% }"
fi

export SPARK_LOCAL_DIRS=$(add_prefix_suffix "$LOCAL_DIRS" "" "/spark/local")
export FLINK_LOCAL_DIRS=$(add_prefix_suffix "$LOCAL_DIRS" "" "/flink/local")

# Create the required subdirectories in REPORT_DIR
if ! mkdir -p "$REPORT_DIR/etc" ; then
	m_exit "Could not create the required configuration directory at $REPORT_DIR/etc"
fi

if ! mkdir -p "$REPORT_BIN_DIR"; then
	m_exit "Could not create the required bin directory at $REPORT_BIN_DIR"
fi

if ! mkdir -p "$REPORT_TOOLS_DIR"; then
	m_exit "Could not create the required tools directory at $REPORT_TOOLS_DIR"
fi

# Copy configuration files into REPORT_DIR
if ! cp -r "$BDEV_CONF_DIR"/* "$REPORT_DIR/etc/"; then
    m_exit "Could not copy configuration files to $REPORT_DIR/etc"
fi

export BDEV_CONF_DIR=$REPORT_DIR/etc
m_echo "Configuration files copied to: $BDEV_CONF_DIR"

# Load remaining configuration files
. $BDEV_CONF_DIR/hdfs.sh
. $BDEV_CONF_DIR/yarn.sh
. $BDEV_CONF_DIR/mapreduce.sh
. $BDEV_CONF_DIR/benchmarks-conf.sh
. $BDEV_CONF_DIR/frameworks-conf.sh

case "$SPARK_API" in
    rdd|dataset)
        ;;
    *)
        m_exit "SPARK_API must be 'rdd' or 'dataset'"
        ;;
esac

if ! [[ "$NUM_EXECUTIONS" =~ ^[0-9]+$ ]] || [[ "$NUM_EXECUTIONS" -lt 1 ]]; then
	m_exit "The number of workload executions must be an integer greater than 0: NUM_EXECUTIONS=${NUM_EXECUTIONS:-<not set>}"
fi

export CLUSTER_SIZES=$(read_list "$BDEV_CONF_DIR/cluster_sizes.lst")
export BENCHMARKS=$(read_list "$BDEV_CONF_DIR/benchmarks.lst")
export FRAMEWORKS=$(read_frameworks_list "$BDEV_CONF_DIR/frameworks.lst")
export NUM_CLUSTERS=$(wc -w <<< "$CLUSTER_SIZES")
export NUM_BENCHMARKS=$(wc -w <<< "$BENCHMARKS")
export NUM_FRAMEWORKS=$(wc -w <<< "$FRAMEWORKS")

if [[ "$NUM_CLUSTERS" -lt 1 ]]; then
	m_exit "No cluster sizes specified. Revise cluster_sizes.lst"
fi

export SLURM_ENV="false"
# Check if we are under a SLURM environment
if [[ -n "$SLURM_JOB_ID" ]]; then
	SLURM_ENV="true"
fi

# Setup default hostfile
if [[ -z $BDEV_HOSTFILE ]]; then
	if [[ "$SLURM_ENV" == "false" ]]; then
		export BDEV_HOSTFILE=$BDEV_CONF_DIR/hostfile
	fi
fi
		
# Setup environment modules
if [[ "$ENABLE_MODULES" == "true" ]]; then
	m_echo "Loading environment modules: ${MODULES_JAVA}"
	module load ${MODULES_JAVA}
	m_echo "Loading environment modules: ${MODULES_PYTHON}"
	module load ${MODULES_PYTHON}
fi

# Check ssh command and options
require_binary SSH_CMD ssh

# Ensure safe defaults for SSH
export BDEV_SSH_OPTS="${BDEV_SSH_OPTS:-"-o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10s -o LogLevel=ERROR"}"

if [[ "$BDEV_SSH_OPTS" != *"BatchMode=yes"* ]]; then
    BDEV_SSH_OPTS="-o BatchMode=yes $BDEV_SSH_OPTS"
fi

# Basic syntax check
if echo " $BDEV_SSH_OPTS" | grep -qE " [a-zA-Z]+="; then
    for token in $BDEV_SSH_OPTS; do
        if [[ "$token" == *"="* ]] && [ "$prev_token" != "-o" ]; then
            m_error "Malformed BDEV_SSH_OPTS: $BDEV_SSH_OPTS"
            m_exit "'$token' is missing the '-o' prefix"
        fi
        prev_token="$token"
    done
fi

export SSH_CMD="$SSH_CMD $BDEV_SSH_OPTS"

# Check java command and version
require_binary JAVA java
export BDEV_JAVA_HOME=$(dirname $(dirname "${JAVA}"))

# Check java version
# Java 8 spits out: version "1.8.0_412" -> We keep "8"
# Java 11 spits out: version "11.0.22" -> We'll stick with "11"
JAVA_VER_STRING=$("$JAVA" -version 2>&1 | awk -F '"' '/version/ {print $2}')
JAVA_MAJOR_VER=$(echo "$JAVA_VER_STRING" | awk -F '.' '{if ($1 == 1) print $2; else print $1}')

# Check jps command
if [[ -x "${BDEV_JAVA_HOME}/bin/jps" ]]; then
	export JPS="${BDEV_JAVA_HOME}/bin/jps"
else
	m_exit "Missing jps command (not found in ${BDEV_JAVA_HOME}/bin)"
fi

# Check ip command
require_binary IP_COMMAND ip

# Check getent command
require_binary RESOLVEIP_COMMAND getent

# Check Python
require_binary PYTHON_BIN python3 python

# Check Python version
PYTHON_MAJOR_VERSION=$($PYTHON_BIN -c 'import sys; print(sys.version_info[0])' 2>/dev/null)

if [[ "$PYTHON_MAJOR_VERSION" != "3" ]]; then
	m_exit "$APP_NAME v$APP_VERSION requires Python 3, but the detected version is Python $PYTHON_MAJOR_VERSION ($PYTHON_BIN)"
fi

# Check gnuplot command
require_binary --warn GNUPLOT_BIN gnuplot

if [[ "$GNUPLOT_BIN" == "null" ]]; then
	m_warn "Plot generation will be disabled because gnuplot was not found"
	ENABLE_RUNTIME_PLOTS="false"
	STAT_GEN_PLOTS="false"
	RAPL_GEN_PLOTS="false"
fi

#Define the JPMS options exclusive to Java 9+
if [[ "$JAVA_MAJOR_VER" -le 8 ]]; then
	export JAVA_JPMS_OPTS=""
else
	export JAVA_JPMS_OPTS="--add-exports=java.base/sun.net.util=ALL-UNNAMED --add-exports=java.rmi/sun.rmi.registry=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED --add-exports=java.security.jgss/sun.security.krb5=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.math=ALL-UNNAMED --add-opens=java.base/java.text=ALL-UNNAMED --add-opens=java.base/java.time=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.locks=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/sun.nio.cs=ALL-UNNAMED --add-opens=java.base/sun.security.action=ALL-UNNAMED --add-opens=java.base/sun.util.calendar=ALL-UNNAMED"
fi

# YARN scheduler class
if [[ ${SCHEDULER_CLASS} == "capacity" ]]; then
	export SCHEDULER_CLASS=org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler
else
	if [[ ${SCHEDULER_CLASS} == "fair" ]]; then
	    export SCHEDULER_CLASS=org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler
	else
	    if [[ ${SCHEDULER_CLASS} == "fifo" ]]; then
		export SCHEDULER_CLASS=org.apache.hadoop.yarn.server.resourcemanager.scheduler.fifo.FifoScheduler
	    else
		m_exit "Invalid YARN scheduler (SCHEDULER_CLASS=$SCHEDULER_CLASS). Revise YARN settings (yarn-default.sh/yarn-conf.sh)"
	    fi
	fi
fi

# Copy dool tool
if [[ $ENABLE_STAT == "true" ]]; then
	if ! mkdir -p "$REPORT_TOOLS_DIR/dool" || ! cp -r "$DOOL_HOME/dool" "$DOOL_HOME/plugins" "$REPORT_TOOLS_DIR/dool/"; then
    		m_exit "Could not copy dool files from $DOOL_HOME to $REPORT_TOOLS_DIR"
	fi

	if ! cp -r "$BDEV_BIN_DIR"/stat "$REPORT_BIN_DIR/"; then
		m_exit "Could not copy dool scripts from "$BDEV_BIN_DIR"/stat to $REPORT_BIN_DIR"
	fi
fi

# Check and copy RAPL binary
if [[ $ENABLE_RAPL == "true" ]]; then
	if [[ ! -f "$RAPL_HOME/rapl_monitor/$RAPL_COMMAND_NAME" || ! -x "$RAPL_HOME/rapl_monitor/$RAPL_COMMAND_NAME" ]]; then
		m_exit "RAPL binary is missing or is not executable"
	fi

	if ! mkdir -p "$REPORT_BIN_DIR/rapl/rapl_monitor" || ! cp "$BDEV_BIN_DIR"/rapl/*.sh "$REPORT_BIN_DIR/rapl/" || ! cp "$BDEV_BIN_DIR"/rapl/rapl_monitor/$RAPL_COMMAND_NAME "$REPORT_BIN_DIR/rapl/rapl_monitor/$RAPL_COMMAND_NAME"; then
		m_exit "Could not copy RAPL scripts from "$BDEV_BIN_DIR"/rapl to $REPORT_BIN_DIR/rapl"
	fi
fi

# Check and copy ocount command for Oprofile
if [[ $ENABLE_OPROFILE == "true" ]]; then
	require_binary OPROFILE_BIN $OPROFILE_BIN

	if ! cp -r "$BDEV_BIN_DIR"/oprofile "$REPORT_BIN_DIR/"; then
		m_exit "Could not copy Oprofile scripts from "$BDEV_BIN_DIR"/oprofile to $REPORT_BIN_DIR"
	fi
fi

# Copy ILO scripts
if [[ $ENABLE_ILO == "true" ]]; then
	if ! cp -r "$ILO_SCRIPTS" "$REPORT_TOOLS_DIR/"; then
    		m_exit "Could not copy ILO scripts from $ILO_SCRIPTS to $REPORT_TOOLS_DIR"
	fi

	if ! cp -r "$BDEV_BIN_DIR"/ilo "$REPORT_BIN_DIR/"; then
		m_exit "Could not copy ILO scripts from "$BDEV_BIN_DIR"/ilo to $REPORT_BIN_DIR"
	fi
fi

# Copy BDWatchdog
if [[ $ENABLE_BDWATCHDOG == "true" ]]; then
	# Define variables for BDWatchdog binary daemons
        if [[ $BDWATCHDOG_ATOP == "true" ]]; then
            export ATOP_BIN=$BDWATCHDOG_DAEMONS_BIN_DIR/atop/atop
	    if [[ ! -f "$ATOP_BIN" || ! -x "$ATOP_BIN" ]]; then
                m_exit "atop is enabled but the binary $ATOP_BIN is missing or is not executable"
            fi
        fi

        if [[ $BDWATCHDOG_TURBOSTAT == "true" ]]; then
	    require_binary TURBOSTAT_BIN $TURBOSTAT_BIN
        fi

        if [[ $BDWATCHDOG_NETHOGS == "true" ]]; then
            export NETHOGS_BIN=$BDWATCHDOG_DAEMONS_BIN_DIR/nethogs/nethogs
	    if [[ ! -f "$NETHOGS_BIN" || ! -x "$NETHOGS_BIN" ]]; then
                m_exit "nethogs is enabled but the binary $NETHOGS_BIN is missing or is not executable"
            fi
        fi
        
	if ! cp -r "$BDWATCHDOG_SRC_DIR" "$REPORT_TOOLS_DIR/"; then
    		m_exit "Could not copy BDWatchdog from $BDWATCHDOG_SRC_DIR to $REPORT_TOOLS_DIR"
	fi
	
	if ! cp -r "$BDEV_BIN_DIR"/bdwatchdog "$REPORT_BIN_DIR/"; then
		m_exit "Could not copy BDWatchdog scripts from "$BDEV_BIN_DIR"/bdwatchdog to $REPORT_BIN_DIR"
	fi
fi

# Copy main binary files into REPORT_DIR
if ! cp -r "$BDEV_BIN_DIR"/*.sh "$BDEV_BIN_DIR"/plot "$BDEV_HELPERS_DIR"/ "$REPORT_BIN_DIR/"; then
	m_exit "Could not copy $APP_NAME binary files from $BDEV_BIN_DIR to $REPORT_BIN_DIR"
fi

# Redefine BDEv bin dirdirectory to the report directory
export BDEV_BIN_DIR=$REPORT_BIN_DIR

# Define IP script
export GET_IP_FROM_HOSTNAME_SCRIPT="$BDEV_BIN_DIR/helpers/get_ip_from_hostname.sh"

# Define hostname script depending on the configured mode
if [[ ${ENABLE_HOSTNAMES} == "true" ]]; then
	export GET_HOSTNAME_SCRIPT="$BDEV_BIN_DIR/helpers/get_hostname.sh"
else
	export GET_HOSTNAME_SCRIPT="$BDEV_BIN_DIR/helpers/get_ip_from_hostname.sh"
fi

#STAT
export STAT_HOME="$BDEV_BIN_DIR/stat"
export STAT_PLOT_HOME="$PLOT_HOME/stat"
export DOOL_HOME="$REPORT_TOOLS_DIR/dool"
export DOOL_COMMAND="$DOOL_HOME/$DOOL_COMMAND_NAME"
export DOOL_OPTIONS="-T -c -C total --load -ms -d --disk-util -fn --noheaders --noupdate --bytes --ascii"

#RAPL
export RAPL_HOME="$BDEV_BIN_DIR/rapl"
export RAPL_PLOT_HOME="$PLOT_HOME/rapl"

#OPROFILE
export OPROFILE_HOME=$BDEV_BIN_DIR/oprofile
export OPROFILE_PLOT_HOME=$PLOT_HOME/oprofile

#ILO
export ILO_HOME=$BDEV_BIN_DIR/ilo
export ILO_SCRIPTS="$REPORT_TOOLS_DIR/ilo-$ILO_SCRIPTS_VERSION"
export ILO_POWER_SCRIPT_TEMPLATE=$ILO_SCRIPTS/Get_Power_Readings.xml
export ILO_CONFIG_SCRIPT=$ILO_SCRIPTS/locfg.pl

#BDWatchdog
export BDWATCHDOG_HOME="$BDEV_BIN_DIR/bdwatchdog"
export BDWATCHDOG_SRC_DIR="$REPORT_TOOLS_DIR/BDWatchdog"
export BDWATCHDOG_DAEMONS_DIR="$BDWATCHDOG_SRC_DIR/MetricsFeeder/src/daemons"
export BDWATCHDOG_DAEMONS_BIN_DIR="$BDWATCHDOG_SRC_DIR/MetricsFeeder/bin"
export BDWATCHDOG_TIMESTAMPING_SERVICE="$BDWATCHDOG_SRC_DIR/TimestampsSnitch/src"
export ATOP_BIN="$BDWATCHDOG_DAEMONS_BIN_DIR/atop/atop"
export NETHOGS_BIN="$BDWATCHDOG_DAEMONS_BIN_DIR/nethogs/nethogs"

# Print environment for debugging
env > "$REPORT_DIR/env"
