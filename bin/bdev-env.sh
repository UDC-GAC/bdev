#!/bin/sh

export METHOD_NAME=BDEv
export METHOD_VERSION=4.0-dev

if [ -z $BDEV_HOME ]
then
        echo "Error: BDEV_HOME must be set"
	exit -1
fi

export BDEV_CONF_DIR=$BDEV_HOME/etc
export BDEV_BIN_DIR=$BDEV_HOME/bin
export BDEV_START_DATE=`date +"%d_%m_%Y_%H-%M-%S-%N"`

# Load bash functions
. $BDEV_BIN_DIR/functions.sh

export THIRD_PARTY_DIR=$BDEV_HOME/third-party
export SOLUTIONS_SRC_DIR=$BDEV_HOME/solutions/src

if [ -z "$SOLUTIONS_DIST_DIR" ]
then
	export SOLUTIONS_DIST_DIR=$BDEV_HOME/solutions/dist
fi

export SOLUTIONS_BENCH_DIR=$BDEV_HOME/solutions/benchmarks
export SOLUTIONS_LIB_DIR=$BDEV_HOME/solutions/lib
export COMMON_BENCH_DIR=$SOLUTIONS_BENCH_DIR/common
export COMMON_SRC_DIR=$SOLUTIONS_SRC_DIR/common
export TEMPLATES_DIR=$BDEV_HOME/solutions/templates
export DAEMONS_DIR=$BDEV_HOME/solutions/daemons
export METHOD_EXP_DIR=$BDEV_HOME/experiment
export INIT_SOL_SCRIPT=$BDEV_BIN_DIR/init-sol.sh
export GEN_CONFIG_SCRIPT=$BDEV_BIN_DIR/gen-config.sh
export COPY_DAEMONS_SCRIPT=$BDEV_BIN_DIR/copy-daemons.sh
export CLEAN_DAEMONS_SCRIPT=$BDEV_BIN_DIR/kill-daemons.sh
export CLEAN_DATA_SCRIPT=$BDEV_BIN_DIR/delete-nodes-data.sh
export YARN_KILLALL_SCRIPT=$BDEV_BIN_DIR/yarn-killall.sh

if [ -z $EXP_DIR ]
then
	export EXP_DIR=$METHOD_EXP_DIR
fi

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
export DOOL_HOME=$THIRD_PARTY_DIR/dool-1.3.1
export DOOL_COMMAND_NAME=dool
export DOOL_COMMAND=$DOOL_HOME/$DOOL_COMMAND_NAME
export DOOL_OPTIONS="-T -c -C total --load -ms -d --disk-util -fn --noheaders --noupdate --bytes"

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
export PYTHONPATH=${BDWATCHDOG_SRC_DIR}

# Load BDEv configuration to define OUT_DIR
. $BDEV_CONF_DIR/bdev-default.sh
. $EXP_DIR/bdev-conf.sh

export REPORT_DIR=${OUT_DIR}/report_${METHOD_NAME}_${BDEV_START_DATE}
export REPORT_FILE=$REPORT_DIR/summary
export REPORT_LOG=$REPORT_DIR/log
export PLOT_DIR=$REPORT_DIR/graphs
export RAPL_PLOT_DIR=$PLOT_DIR/rapl
export OPROFILE_PLOT_DIR=$PLOT_DIR/oprofile
export ILO_DIR=$PLOT_DIR/ilo
export REPORT_GEN_GRAPHS_FILE=${REPORT_DIR}/gen_all_graphs.sh

# Check if we are under a SLURM environment
if [[ -n "$SLURM_JOB_ID" ]]
then
        export SLURM_ENV="true"
fi

if [[ ! -d $REPORT_DIR ]]
then
        mkdir -p $REPORT_DIR
	mkdir -p $REPORT_DIR/etc
	mkdir -p $REPORT_DIR/experiment
fi

# Copy configuration to REPORT_DIR
cp $BDEV_CONF_DIR/*-default.sh $REPORT_DIR/etc
cp $EXP_DIR/*-conf.sh $REPORT_DIR/experiment
cp $EXP_DIR/*.lst $REPORT_DIR/experiment
cp $EXP_DIR/*-scheduler.xml $REPORT_DIR/experiment

export BDEV_CONF_DIR=$REPORT_DIR/etc

# Load default configuration
. $BDEV_CONF_DIR/bdev-default.sh
. $BDEV_CONF_DIR/system-default.sh
. $BDEV_CONF_DIR/experiment-default.sh

export HOSTFILE_DEFAULT=$EXP_DIR/hostfile

if [[ -z $HOSTFILE ]]
then
	if [[ "$SLURM_ENV" == "true" ]]
	then
		COMPUTE_NODES=`scontrol show hostname $SLURM_JOB_NODELIST`
	else
		HOSTFILE=$HOSTFILE_DEFAULT
	fi
fi

. $EXP_DIR/bdev-conf.sh
. $EXP_DIR/system-conf.sh
. $EXP_DIR/experiment-conf.sh

export CLUSTER_SIZES=`read_list $EXP_DIR/cluster_sizes.lst`
export BENCHMARKS=`read_list $EXP_DIR/benchmarks.lst`
export SOLUTIONS=`read_solutions $EXP_DIR/solutions.lst`
export NUM_CLUSTERS=`echo $CLUSTER_SIZES | wc -w`
export NUM_BENCHMARKS=`echo $BENCHMARKS | wc -w`
export NUM_SOLUTIONS=`echo $SOLUTIONS | wc -w`

if [[ -z "$LOCAL_DIRS" ]]
then
	export LOCAL_DIRS=${TMP_DIR}
else
	export LOCAL_DIRS="`echo $LOCAL_DIRS | tr "," " "`"
fi

. $BDEV_CONF_DIR/core-default.sh
. $EXP_DIR/core-conf.sh

. $BDEV_CONF_DIR/hdfs-default.sh
. $EXP_DIR/hdfs-conf.sh

. $BDEV_CONF_DIR/yarn-default.sh
. $EXP_DIR/yarn-conf.sh

. $BDEV_CONF_DIR/mapred-default.sh
. $EXP_DIR/mapred-conf.sh

. $BDEV_CONF_DIR/solutions-default.sh
. $EXP_DIR/solutions-conf.sh

m_echo "Running $METHOD_NAME v$METHOD_VERSION"

# Check ssh command
SSH_CMD=$(which ssh 2> /dev/null)
if [[ "x$SSH_CMD" == "x" ]]; then
        m_exit "Missing ssh command"
fi

if [[ ! -f "$SSH_CMD" ]]; then
	m_exit "Missing ssh command: $SSH_CMD"
elif [[ ! -x "$SSH_CMD" ]]; then
	m_exit "ssh command is not executable: $SSH_CMD"
fi

export SSH_CMD="$SSH_CMD $SSH_OPTS"

# Check modules environment
if [[ "$ENABLE_MODULES" == "true" ]]; then
        if [[ -z $LOAD_JAVA_COMMAND ]]; then
                export LOAD_JAVA_COMMAND="module load ${MODULE_JAVA}"
        fi
else
        if [[ -z $LOAD_JAVA_COMMAND ]]; then
                JAVA=$(which java 2> /dev/null)

                if [[ "x$JAVA" == "x" ]]; then
                        m_exit "Missing java command"
                fi

		if [[ ! -f "$JAVA" ]]; then
        		m_exit "Missing java command: $JAVA"
		elif [[ ! -x "$JAVA" ]]; then
        		m_exit "java command is not executable: $JAVA"
		fi

                export JAVA_HOME=$(dirname $(dirname $(readlink -f ${JAVA})))
                export LOAD_JAVA_COMMAND="export JAVA_HOME=$JAVA_HOME"
		export JPS=$(which jps 2> /dev/null)

                if [[ "x$JPS" == "x" ]]; then
                        m_exit "Missing jps command"
                fi
		if [[ ! -f "$JPS" ]]; then
        		m_exit "Missing jps command: $JPS"
		fi
        fi
fi

# Check expect command
export EXPECT=$(which expect 2> /dev/null)
if [[ "x$EXPECT" == "x" ]]; then
	m_warn "Missing expect command (required when using timeouts)"
fi

# Define variables for BDWatchdog binary daemons
if [[ $ENABLE_BDWATCHDOG == "true" ]]; then
        if [[ $BDWATCHDOG_ATOP == "true" ]]; then
                export ATOP_BIN=$BDWATCHDOG_DAEMONS_BIN_DIR/atop/atop
		if [[ ! -f "$ATOP_BIN" ]] || [[ ! -x "$ATOP_BIN" ]]; then
                        m_exit "atop is enabled but the binary $ATOP_BIN is not found or is not executable"
                fi
        fi
        if [[ $BDWATCHDOG_TURBOSTAT == "true" ]]; then
		export TURBOSTAT_BIN=$TURBOSTAT_BIN_DIR/turbostat
                if [[ ! -f "$TURBOSTAT_BIN" ]] || [[ ! -x "$TURBOSTAT_BIN" ]]; then
                        m_exit "turbostat is enabled but the binary $TURBOSTAT_BIN is not found or is not executable"
                fi
        fi
        if [[ $BDWATCHDOG_NETHOGS == "true" ]]; then
                export NETHOGS_BIN=$BDWATCHDOG_DAEMONS_BIN_DIR/nethogs/nethogs
		if [[ ! -f "$NETHOGS_BIN" ]] || [[ ! -x "$NETHOGS_BIN" ]]; then
                        m_exit "nethogs is enabled but the binary $NETHOGS_BIN is not found or is not executable"
                fi
        fi
fi

if [[ ${ENABLE_HOSTNAMES} == "true" ]]; then
	export HOSTNAME_SCRIPT=get_hostname.sh
else
	export HOSTNAME_SCRIPT=get_ip_from_hostname.sh
fi

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
