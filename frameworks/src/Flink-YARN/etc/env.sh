#!/bin/sh
export SOL_BENCH_DIR=$BENCHMARKS_DIR/Flink
export SOL_TEMPLATE_DIR=$TEMPLATES_DIR/Flink
export SOL_DAEMONS_DIR=$DAEMONS_DIR/Flink
export SOL_SBIN_DIR=$SOLUTION_HOME/bin
export SOL_CONF_DIR_SRC=$SOLUTION_HOME/conf
export SOL_CONF_DIR=$SOLUTION_REPORT_DIR/conf/flink
export SOL_LOG_DIR=$SOLUTION_REPORT_DIR/logs/flink
export SOL_LIB_DIR=$SOLUTION_HOME/lib
export MASTERFILE=$SOL_CONF_DIR/masters
export SLAVESFILE=$SOL_CONF_DIR/workers

#FLINK
export FLINK_HOME=$SOLUTION_HOME
export FLINK_VERSION=${SOLUTION_HOME##*/}
export FLINK_MAJOR_VERSION=${FLINK_VERSION%.*}
export FLINK_SERIES=${FLINK_VERSION%%.*}
export FLINK_CONF_DIR=$SOL_CONF_DIR
export FLINK_SBIN_DIR=$SOL_SBIN_DIR
export FLINK_LOG_DIR=$SOL_LOG_DIR
export PATH=$FLINK_HOME/bin:$PATH
export FLINK_TASKMANAGERS=$(($FLINK_TASKMANAGERS_PER_NODE * $SLAVES_NUMBER))
export FLINK_PARALLELISM=$(($FLINK_TASKMANAGERS * $FLINK_TASKMANAGER_SLOTS))
export FLINK_CONFIG_YAML_FILE=$SOL_CONF_DIR/flink-conf.yaml
export FLINK_HADOOP_CLASSPATH=$SOL_CONF_DIR/classpath
export HIVE_VERSION=$HADOOP_HIVE_VERSION
export HIVE_HOME=$THIRD_PARTY_DIR/hive-$HIVE_VERSION

if [ -d $HIVE_HOME ]; then
	export HADOOP_CLASSPATH="$HADOOP_CLASSPATH:$HIVE_HOME/lib/*"
fi

if [ $FLINK_SERIES == "1" ]; then
	if [ $FLINK_MAJOR_VERSION != "1.20" ] &&
		[ $FLINK_MAJOR_VERSION != "1.19" ] &&
		[ $FLINK_MAJOR_VERSION != "1.18" ] &&
		[ $FLINK_MAJOR_VERSION != "1.17" ] &&
		[ $FLINK_MAJOR_VERSION != "1.16" ] &&
		[ $FLINK_MAJOR_VERSION != "1.15" ]; then
		m_exit "Flink version is not supported: $FLINK_VERSION"
	fi
else
        m_exit "Flink version is not supported: $FLINK_VERSION"
fi

# Hadoop
export HADOOP_HOME=$FLINK_HADOOP_HOME
. $COMMON_SRC_DIR/etc/env.sh

#Configuration
export OLD_GEN_CONFIG_SCRIPT=$GEN_CONFIG_SCRIPT
export GEN_CONFIG_SCRIPT=$SOLUTION_DIR/bin/gen-config.sh

#Deploy mode
export FINISH_YARN="false"
# Session Mode
export DEPLOY_ARGS="run -t yarn-session"
export YARN_PROPS_FILE_CUSTOM="$TMP_DIR/.yarn-properties-$USER"
export YARN_PROPS_FILE_DEFAULT="/tmp/.yarn-properties-$USER"
export YARN_APP_ID=""

# Set and copy config.sh file according to Flink version
FLINK_CONFIG_SH_FILE=$SOL_DAEMONS_DIR/config/config-${FLINK_MAJOR_VERSION}.sh

if [ ! -f $FLINK_CONFIG_SH_FILE ]; then
        m_exit "Flink config.sh file not found: $FLINK_CONFIG_SH_FILE"
else
	m_echo "Copying Flink config.sh file: $FLINK_CONFIG_SH_FILE"
	cp -f $FLINK_CONFIG_SH_FILE $SOL_SBIN_DIR/config.sh
fi

# Copy MapReduce jar
export MAPREDUCE_JAR_FILE=$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-core-*.jar
if [ ! -f $MAPREDUCE_JAR_FILE ]; then
	m_exit "MapReduce jar not found: $MAPREDUCE_JAR_FILE"
else
	cp -f $MAPREDUCE_JAR_FILE $SOL_LIB_DIR
fi

add_conf_param "flink_conf_dir" $FLINK_CONF_DIR
add_conf_param "flink_log_dir" $FLINK_LOG_DIR
add_conf_param "flink_default_parallelism" $FLINK_PARALLELISM
add_conf_param "flink_jobmanager_memory" $FLINK_YARN_JOBMANAGER_MEMORY
add_conf_param "flink_taskmanager_memory" $FLINK_YARN_TASKMANAGER_MEMORY
