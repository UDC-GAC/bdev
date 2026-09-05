#!/bin/bash
export SOL_BENCH_DIR=$BENCHMARKS_DIR/Flink
export SOL_TEMPLATE_DIR=$TEMPLATES_DIR/Flink
export SOL_CONF_DIR_SRC=$SOLUTION_HOME/conf
export SOL_CONF_DIR=$SOLUTION_REPORT_DIR/conf/flink
export SOL_LOG_DIR=$SOLUTION_REPORT_DIR/logs/flink
export SOL_GEN_CONFIG_SCRIPT=$SOLUTION_DIR/bin/gen-config.sh
export MASTERFILE=$SOL_CONF_DIR/masters
export WORKERSFILE=$SOL_CONF_DIR/workers

#FLINK
export FLINK_HOME=$SOLUTION_HOME
export FLINK_VERSION=${SOLUTION_HOME##*/}
export FLINK_MAJOR_VERSION=${FLINK_VERSION%.*}
export FLINK_SERIES=${FLINK_VERSION%%.*}
export FLINK_CONF_DIR=$SOL_CONF_DIR
export FLINK_LOG_DIR=$SOL_LOG_DIR
export PATH=$FLINK_HOME/bin:$PATH
export FLINK_TASKMANAGERS=$(($FLINK_TASKMANAGERS_PER_NODE * $WORKERS_NUMBER))
export FLINK_PARALLELISM=$(($FLINK_TASKMANAGERS * $FLINK_TASKMANAGER_SLOTS))
export FLINK_CONFIG_YAML_FILE=$SOL_CONF_DIR/flink-conf.yaml
export FLINK_HADOOP_CLASSPATH=$SOL_CONF_DIR/classpath
export FLINK_SSH_OPTS="${BDEV_SSH_OPTS}"

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

#Deploy mode
export FINISH_YARN="true"
# Session Mode
export DEPLOY_ARGS="run -p ${FLINK_PARALLELISM}"

add_conf_param "flink_conf_dir" $FLINK_CONF_DIR
add_conf_param "flink_log_dir" $FLINK_LOG_DIR
add_conf_param "flink_default_parallelism" $FLINK_PARALLELISM
add_conf_param "flink_jobmanager_memory" $FLINK_JOBMANAGER_MEMORY
add_conf_param "flink_taskmanager_memory" $FLINK_TASKMANAGER_MEMORY
