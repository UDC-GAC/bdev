#!/bin/sh

export APP_NAME=BDEv
export APP_VERSION=4.0-dev

if [ -z $BDEV_HOME ]; then
        echo "Error: BDEV_HOME must be set"
	exit -1
fi

export BDEV_CONF_DIR=$BDEV_HOME/etc
export BDEV_BIN_DIR=$BDEV_HOME/bin
export BDEV_START_DATE=`date +"%d_%m_%Y_%H-%M-%S-%N"`

if [ -z $BDEV_EXPERIMENT_DIR ]; then
	export BDEV_EXPERIMENT_DIR=$BDEV_CONF_DIR
fi

if [ -z "$FRAMEWORKS_DIR" ]; then
	export FRAMEWORKS_DIR=$BDEV_HOME/frameworks/dist
fi

export SOLUTIONS_SRC_DIR=$BDEV_HOME/frameworks/src
export BENCHMARKS_DIR=$BDEV_HOME/benchmarks
export COMMON_BENCH_DIR=$BENCHMARKS_DIR/common
export COMMON_SRC_DIR=$SOLUTIONS_SRC_DIR/common
export SOLUTIONS_LIB_DIR=$BDEV_HOME/frameworks/lib
export TEMPLATES_DIR=$BDEV_HOME/frameworks/templates
export DAEMONS_DIR=$BDEV_HOME/frameworks/daemons
export THIRD_PARTY_DIR=$BDEV_HOME/third-party
export INIT_SOL_SCRIPT=$BDEV_BIN_DIR/init-sol.sh
export GEN_CONFIG_SCRIPT=$BDEV_BIN_DIR/gen-config.sh
export COPY_DAEMONS_SCRIPT=$BDEV_BIN_DIR/copy-daemons.sh
export CLEAN_DAEMONS_SCRIPT=$BDEV_BIN_DIR/kill-daemons.sh
export CLEAN_DATA_SCRIPT=$BDEV_BIN_DIR/delete-nodes-data.sh
export YARN_KILLALL_SCRIPT=$BDEV_BIN_DIR/yarn-killall.sh

#ILO
export ILO_HOME=$BDEV_BIN_DIR/ilo
export ILO_SCRIPTS=$THIRD_PARTY_DIR/ilo-5.30.0
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

# Load functions
. $BDEV_BIN_DIR/functions.sh
# Load BDEv and system configuration files
. $BDEV_EXPERIMENT_DIR/bdev-conf.sh
. $BDEV_EXPERIMENT_DIR/system-conf.sh

export REPORT_DIR=${OUT_DIR}/report_${APP_NAME}_${BDEV_START_DATE}
export REPORT_FILE=$REPORT_DIR/summary
export REPORT_LOG=$REPORT_DIR/log
export REPORT_GEN_GRAPHS_FILE=${REPORT_DIR}/gen_all_graphs.sh
export PLOT_DIR=$REPORT_DIR/graphs
export RAPL_PLOT_DIR=$PLOT_DIR/rapl
export OPROFILE_PLOT_DIR=$PLOT_DIR/oprofile
export ILO_DIR=$PLOT_DIR/ilo

if [ ! -d $REPORT_DIR ]; then
    mkdir -p $REPORT_DIR
	mkdir -p $REPORT_DIR/etc
fi

m_echo "Running $APP_NAME v$APP_VERSION"
m_echo "Reporting to $REPORT_DIR"

if [ ! -d "$BDEV_EXPERIMENT_DIR" ]; then
	m_exit "BDEV_EXPERIMENT_DIR does not exist or is not a directory: $BDEV_EXPERIMENT_DIR"
fi

if [ ! -d "$FRAMEWORKS_DIR" ]; then
	m_exit "FRAMEWORKS_DIR does not exist or is not a directory: $FRAMEWORKS_DIR"
fi

export BDEV_EXPERIMENT_DIR=$(cd "$BDEV_EXPERIMENT_DIR" && pwd)
m_echo "Configuration directory: $BDEV_EXPERIMENT_DIR"

if [ -z "$STORAGE_BACKEND" ]; then
	export STORAGE_BACKEND=hdfs
	m_warn "STORAGE_BACKEND is not defined or is empty. Setting it to \"hdfs\""
fi

if [ "${STORAGE_BACKEND,,}" == "nfs" ]; then
    if [ ! -d "$NFS_MOUNT_POINT" ]; then
        m_exit "NFS_MOUNT_POINT does not exist or is not a directory: $NFS_MOUNT_POINT"
    fi
    
    if ! is_nfs "$NFS_MOUNT_POINT"; then
        m_exit "NFS_MOUNT_POINT is not a directory mounted using NFS: $NFS_MOUNT_POINT"
    fi

	export NFS_MOUNT_POINT=$(cd "$NFS_MOUNT_POINT" && pwd)
fi

if [ -z "$TMP_DIR" ]; then
	m_exit "TMP_DIR is not defined or is empty. Revise system-conf.sh"
fi

if [ -z "$LOCAL_DIRS" ]; then
	export LOCAL_DIRS=${TMP_DIR}
	m_warn "LOCAL_DIRS is not defined or is empty. Setting it to $TMP_DIR"
else
	export LOCAL_DIRS="`echo $LOCAL_DIRS | tr "," " "`"
fi

# Copy configuration to REPORT_DIR
cp -r $BDEV_EXPERIMENT_DIR/* $REPORT_DIR/etc
export BDEV_EXPERIMENT_DIR=$REPORT_DIR/etc
m_echo "Configuration copied to: $BDEV_EXPERIMENT_DIR"

# Load remaining configuration files
. $BDEV_EXPERIMENT_DIR/hdfs.sh
. $BDEV_EXPERIMENT_DIR/yarn.sh
. $BDEV_EXPERIMENT_DIR/mapreduce.sh
. $BDEV_EXPERIMENT_DIR/benchmarks-conf.sh
. $BDEV_EXPERIMENT_DIR/frameworks-conf.sh

case "$SPARK_API" in
    rdd|dataset)
        ;;
    *)
        m_exit "SPARK_API must be 'rdd' or 'dataset'"
        ;;
esac

export HOSTFILE_DEFAULT=$BDEV_EXPERIMENT_DIR/hostfile
export CLUSTER_SIZES=`read_list $BDEV_EXPERIMENT_DIR/cluster_sizes.lst`
export BENCHMARKS=`read_list $BDEV_EXPERIMENT_DIR/benchmarks.lst`
export SOLUTIONS=`read_solutions $BDEV_EXPERIMENT_DIR/frameworks.lst`
export NUM_CLUSTERS=`echo $CLUSTER_SIZES | wc -w`
export NUM_BENCHMARKS=`echo $BENCHMARKS | wc -w`
export NUM_SOLUTIONS=`echo $SOLUTIONS | wc -w`

# Check if we are under a SLURM environment
if [ -n "$SLURM_JOB_ID" ]; then
    export SLURM_ENV="true"
fi

# Setup hostfile
if [ -z $HOSTFILE ]; then
	if [ "$SLURM_ENV" == "true" ]; then
		COMPUTE_NODES=`scontrol show hostname $SLURM_JOB_NODELIST`
	else
		HOSTFILE=$HOSTFILE_DEFAULT
	fi
fi

# Check ssh command
SSH_CMD=$(which ssh 2> /dev/null)
if [ "x$SSH_CMD" == "x" ]; then
        m_exit "Missing ssh command"
fi
if [ ! -f "$SSH_CMD" ]; then
	m_exit "Missing ssh command: $SSH_CMD"
elif [ ! -x "$SSH_CMD" ]; then
	m_exit "ssh command is not executable: $SSH_CMD"
fi

export SSH_CMD="$SSH_CMD $SSH_OPTS"

if [ "$ENABLE_MODULES" == "true" ]; then
	module load ${MODULES_JAVA}
	module load ${MODULES_PYTHON}
fi

# Check JVM
export JAVA=$(which java 2> /dev/null)

if [ "x$JAVA" == "x" ]; then
    m_exit "Missing java command"
fi

if [ ! -f "$JAVA" ]; then
    m_exit "Missing java command: $JAVA"
elif [ ! -x "$JAVA" ]; then
    m_exit "java command is not executable: $JAVA"
fi

export BDEV_JAVA_HOME=$(dirname $(dirname $(readlink -f ${JAVA})))

# Check jps command
export JPS=$(which jps 2> /dev/null)

if [ "x$JPS" == "x" ]; then
    m_exit "Missing jps command"
fi
if [ ! -f "$JPS" ]; then
    m_exit "Missing jps command: $JPS"
elif [ ! -x "$JPS" ]; then
    m_exit "jps command is not executable: $JPS"
fi

# Check Python
export PYTHON_BIN=$(which python 2> /dev/null)

if [ "x$PYTHON_BIN" == "x" ]; then
    m_exit "Missing python command"
fi

if [ ! -f "$PYTHON_BIN" ]; then
    m_exit "Missing PYTHON_BIN command: $PYTHON_BIN"
elif [ ! -x "$PYTHON_BIN" ]; then
    m_exit "python command is not executable: $PYTHON_BIN"
fi

# Check expect command
export EXPECT=$(which expect 2> /dev/null)

if [ "x$EXPECT" == "x" ]; then
	m_warn "Missing expect command (required when using timeouts)"
fi
if [ ! -f "$EXPECT" ]; then
    m_exit "Missing expect command: $EXPECT (required when using timeouts)"
elif [ ! -x "$EXPECT" ]; then
    m_exit "expect command is not executable: $EXPECT (required when using timeouts)"
fi
		
# Define variables for BDWatchdog binary daemons
if [ $ENABLE_BDWATCHDOG == "true" ]; then
        if [ $BDWATCHDOG_ATOP == "true" ]; then
            export ATOP_BIN=$BDWATCHDOG_DAEMONS_BIN_DIR/atop/atop
			if [ ! -f "$ATOP_BIN" ] || [ ! -x "$ATOP_BIN" ]; then
                m_exit "atop is enabled but the binary $ATOP_BIN is not found or is not executable"
            fi
        fi
        if [ $BDWATCHDOG_TURBOSTAT == "true" ]; then
			export TURBOSTAT_BIN=$TURBOSTAT_BIN_DIR/turbostat
            if [ ! -f "$TURBOSTAT_BIN" ] || [ ! -x "$TURBOSTAT_BIN" ]; then
                 m_exit "turbostat is enabled but the binary $TURBOSTAT_BIN is not found or is not executable"
            fi
        fi
        if [ $BDWATCHDOG_NETHOGS == "true" ]; then
            export NETHOGS_BIN=$BDWATCHDOG_DAEMONS_BIN_DIR/nethogs/nethogs
			if [ ! -f "$NETHOGS_BIN" ] || [ ! -x "$NETHOGS_BIN" ]; then
                m_exit "nethogs is enabled but the binary $NETHOGS_BIN is not found or is not executable"
            fi
        fi
fi

if [ ${ENABLE_HOSTNAMES} == "true" ]; then
	export HOSTNAME_SCRIPT=get_hostname.sh
else
	export HOSTNAME_SCRIPT=get_ip_from_hostname.sh
fi

if [ ${SCHEDULER_CLASS} == "capacity" ]; then
	export SCHEDULER_CLASS=org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler
else
	if [ ${SCHEDULER_CLASS} == "fair" ]; then
		export SCHEDULER_CLASS=org.apache.hadoop.yarn.server.resourcemanager.scheduler.fair.FairScheduler
	else
		if [ ${SCHEDULER_CLASS} == "fifo" ]; then
			export SCHEDULER_CLASS=org.apache.hadoop.yarn.server.resourcemanager.scheduler.fifo.FifoScheduler
		else
			m_exit "Invalid YARN scheduler (SCHEDULER_CLASS=$SCHEDULER_CLASS). Revise YARN settings (yarn-default.sh/yarn-conf.sh)"
		fi
	fi
fi
