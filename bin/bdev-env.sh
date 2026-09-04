#!/bin/bash

export APP_NAME=BDEv
export APP_VERSION=4.0.1-dev

if [[ -z $BDEV_HOME ]]; then
        echo "Error: BDEV_HOME must be set"
	exit -1
fi

export BDEV_START_DATE=$(date +"%d_%m_%Y_%H-%M-%S-%N")
export BDEV_DEFAULT_CONF_DIR=$BDEV_HOME/etc
export BDEV_BIN_DIR=$BDEV_HOME/bin
export BDEV_CLEANUP_DIR=$BDEV_HOME/bin/cleanup
export SOLUTIONS_SRC_DIR=$BDEV_HOME/frameworks/src
export BENCHMARKS_DIR=$BDEV_HOME/benchmarks
export COMMON_BENCH_DIR=$BENCHMARKS_DIR/common
export COMMON_SRC_DIR=$SOLUTIONS_SRC_DIR/common
export SOLUTIONS_LIB_DIR=$BDEV_HOME/frameworks/lib
export TEMPLATES_DIR=$BDEV_HOME/frameworks/templates
export DAEMONS_DIR=$BDEV_HOME/frameworks/daemons
export THIRD_PARTY_DIR=$BDEV_HOME/third-party
export INIT_SCRIPT=$BDEV_BIN_DIR/init-framework.sh
export GEN_CONFIG_SCRIPT=$BDEV_BIN_DIR/gen-config.sh
export COPY_DAEMONS_SCRIPT=$BDEV_BIN_DIR/copy-daemons.sh
export CLEANUP_PROCESS_SCRIPT=$BDEV_CLEANUP_DIR/cleanup-process.sh
export CLEANUP_DATA_SCRIPT=$BDEV_CLEANUP_DIR/cleanup-data.sh
export CLEANUP_YARN_SCRIPT=$BDEV_CLEANUP_DIR/cleanup-yarn.sh
export CLEANUP_ON_EXIT="false"
export USER=${USER:-$(id -nu)}

#ILO
export ILO_HOME=$BDEV_BIN_DIR/ilo
export ILO_SCRIPTS=$THIRD_PARTY_DIR/ilo-6.00.0
export ILO_POWER_SCRIPT_TEMPLATE=$ILO_SCRIPTS/Get_Power_Readings.xml
export ILO_CONFIG_SCRIPT=$ILO_SCRIPTS/locfg.pl

#PLOT
export PLOT_HOME=$BDEV_BIN_DIR/plot

#STAT
export STAT_HOME=$BDEV_BIN_DIR/stat
export STAT_PLOT_HOME=$PLOT_HOME/stat
export DOOL_HOME=$THIRD_PARTY_DIR/dool-1.3.8
export DOOL_COMMAND_NAME=dool
export DOOL_COMMAND=$DOOL_HOME/$DOOL_COMMAND_NAME
export DOOL_OPTIONS="-T -c -C total --load -ms -d --disk-util -fn --noheaders --noupdate --bytes --ascii"

#RAPL
export RAPL_HOME=$BDEV_BIN_DIR/rapl
export RAPL_PLOT_HOME=$PLOT_HOME/rapl

#OPROFILE
export OPROFILE_HOME=$BDEV_BIN_DIR/oprofile
export OPROFILE_PLOT_HOME=$PLOT_HOME/oprofile

#BDWatchdog
export BDWATCHDOG_HOME=$BDEV_BIN_DIR/bdwatchdog
export BDWATCHDOG_SRC_DIR=$THIRD_PARTY_DIR/BDWatchdog
export BDWATCHDOG_DAEMONS_DIR=$BDWATCHDOG_SRC_DIR/MetricsFeeder/src/daemons
export BDWATCHDOG_DAEMONS_BIN_DIR=$BDWATCHDOG_SRC_DIR/MetricsFeeder/bin
export BDWATCHDOG_TIMESTAMPING_SERVICE=$BDWATCHDOG_SRC_DIR/TimestampsSnitch/src

# Load BDEv functions
. $BDEV_BIN_DIR/functions.sh

if [[ -z $BDEV_CONF_DIR ]]; then
	PRINT_CONF_DIR_WARNING=true
	export BDEV_CONF_DIR=$BDEV_DEFAULT_CONF_DIR
fi

if [[ -z "$BDEV_FRAMEWORKS_DIR" ]]; then
	export BDEV_FRAMEWORKS_DIR=$BDEV_HOME/frameworks/dist
fi

# Load BDEv and system configuration files
. $BDEV_CONF_DIR/bdev-conf.sh
. $BDEV_CONF_DIR/system-conf.sh

export REPORT_DIR=${OUTPUT_DIR}/report_${APP_NAME}_${BDEV_START_DATE}
export REPORT_FILE=$REPORT_DIR/summary
export REPORT_LOG=$REPORT_DIR/log
export REPORT_GEN_GRAPHS_FILE=${REPORT_DIR}/gen_all_plots.sh
export HELPER_SCRIPTS_DIR=${REPORT_DIR}/helper_scripts
export PLOT_DIR=$REPORT_DIR/plots
export RAPL_PLOT_DIR=$PLOT_DIR/rapl
export OPROFILE_PLOT_DIR=$PLOT_DIR/oprofile
export ILO_DIR=$PLOT_DIR/ilo

if ! mkdir -p "$REPORT_DIR" ; then
	m_exit "Could not create report directory at $REPORT_DIR"
fi

m_echo "$APP_NAME v$APP_VERSION"
m_echo "Reporting to $REPORT_DIR"

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

# Storage backend
if [[ -z "$STORAGE_BACKEND" ]]; then
	export STORAGE_BACKEND=hdfs
	m_warn "STORAGE_BACKEND is not defined or is empty. Setting it to \"hdfs\""
fi

if [[ "${STORAGE_BACKEND,,}" == "nfs" ]]; then
	if [[ ! -d "$NFS_MOUNT_POINT" ]]; then
	        m_exit "NFS_MOUNT_POINT does not exist or is not a directory: $NFS_MOUNT_POINT"
	fi
    
	if ! is_nfs "$NFS_MOUNT_POINT"; then
	        m_exit "NFS_MOUNT_POINT is not a directory mounted using NFS: $NFS_MOUNT_POINT"
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

export SPARK_LOCAL_DIRS=$(add_prefix_sufix "$LOCAL_DIRS" "" "/spark/local")
export FLINK_LOCAL_DIRS=$(add_prefix_sufix "$LOCAL_DIRS" "" "/flink/local")

# Copy configuration to REPORT_DIR
if ! mkdir -p "$REPORT_DIR/etc" "$HELPER_SCRIPTS_DIR"; then
	m_exit "Could not create the required report subdirectories"
fi

if ! cp -r "$BDEV_CONF_DIR"/* "$REPORT_DIR/etc/"; then
    m_exit "Could not copy configuration files to $REPORT_DIR/etc"
fi

export BDEV_CONF_DIR=$REPORT_DIR/etc
m_echo "Configuration copied to: $BDEV_CONF_DIR"

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
export SOLUTIONS=$(read_frameworks_list "$BDEV_CONF_DIR/frameworks.lst")
export NUM_CLUSTERS=$(wc -w <<< "$CLUSTER_SIZES")
export NUM_BENCHMARKS=$(wc -w <<< "$BENCHMARKS")
export NUM_SOLUTIONS=$(wc -w <<< "$SOLUTIONS")

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

#Define the JPMS options exclusive to Java 9+
if [[ "$JAVA_MAJOR_VER" -le 8 ]]; then
	export JAVA_JPMS_OPTS=""
else
	export JAVA_JPMS_OPTS="--add-exports=java.base/sun.net.util=ALL-UNNAMED --add-exports=java.rmi/sun.rmi.registry=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED --add-exports=jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED --add-exports=java.security.jgss/sun.security.krb5=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.lang.invoke=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.math=ALL-UNNAMED --add-opens=java.base/java.text=ALL-UNNAMED --add-opens=java.base/java.time=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.locks=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.base/sun.nio.cs=ALL-UNNAMED --add-opens=java.base/sun.security.action=ALL-UNNAMED --add-opens=java.base/sun.util.calendar=ALL-UNNAMED"
fi

# Copy helper scripts
if ! cp "$BDEV_BIN_DIR/helpers"/* "$HELPER_SCRIPTS_DIR/"; then
    m_exit "Could not copy helper scripts to $HELPER_SCRIPTS_DIR"
fi

# Define ip script
export GET_IP_FROM_HOSTNAME_SCRIPT="$HELPER_SCRIPTS_DIR/get_ip_from_hostname.sh"

# Define hostname script depending on the configured mode
if [[ ${ENABLE_HOSTNAMES} == "true" ]]; then
	export GET_HOSTNAME_SCRIPT="$HELPER_SCRIPTS_DIR/get_hostname.sh"
else
	export GET_HOSTNAME_SCRIPT="$HELPER_SCRIPTS_DIR/get_ip_from_hostname.sh"
fi

# Check ocount command for Oprofile
if [[ $ENABLE_OPROFILE == "true" ]]; then
	require_binary OPROFILE_BIN $OPROFILE_BIN
fi

# Define variables for BDWatchdog binary daemons
if [[ $ENABLE_BDWATCHDOG == "true" ]]; then
        if [[ $BDWATCHDOG_ATOP == "true" ]]; then
            export ATOP_BIN=$BDWATCHDOG_DAEMONS_BIN_DIR/atop/atop
	    if [[ ! -f "$ATOP_BIN" || ! -x "$ATOP_BIN" ]]; then
                m_exit "atop is enabled but the binary $ATOP_BIN is not found or is not executable"
            fi
        fi
        if [[ $BDWATCHDOG_TURBOSTAT == "true" ]]; then
	    require_binary TURBOSTAT_BIN $TURBOSTAT_BIN
        fi
        if [[ $BDWATCHDOG_NETHOGS == "true" ]]; then
            export NETHOGS_BIN=$BDWATCHDOG_DAEMONS_BIN_DIR/nethogs/nethogs
	    if [[ ! -f "$NETHOGS_BIN" || ! -x "$NETHOGS_BIN" ]]; then
                m_exit "nethogs is enabled but the binary $NETHOGS_BIN is not found or is not executable"
            fi
        fi
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
