#!/bin/bash

export SOLUTION_TEMPLATE_DIR=$TEMPLATES_DIR/Flink
export SOLUTION_CONF_DIR_SRC=$SOLUTION_HOME/conf
export SOLUTION_CONF_DIR=$SOLUTION_REPORT_DIR/conf/flink
export SOLUTION_LOG_DIR=$SOLUTION_REPORT_DIR/logs/flink
export SOLUTION_LIB_DIR="$SOLUTION_REPORT_DIR/lib"
export SOLUTION_BENCH_DIR=$BENCHMARKS_DIR/Flink
export MASTERFILE=$SOLUTION_CONF_DIR/masters
export WORKERSFILE=$SOLUTION_CONF_DIR/workers

#FLINK
export FLINK_HOME="$SOLUTION_HOME"
export FLINK_CONF_DIR="$SOLUTION_CONF_DIR"
export FLINK_LOG_DIR="$SOLUTION_LOG_DIR"
export FLINK_LIB_DIR="$SOLUTION_LIB_DIR"
export PATH="$FLINK_HOME/bin:$PATH"
export FLINK_SSH_OPTS="${BDEV_SSH_OPTS}"
export FLINK_CONFIG_YAML_FILE="$SOLUTION_CONF_DIR/flink-conf.yaml"
export FLINK_VERSION="${SOLUTION_HOME##*/}"
export FLINK_MAJOR_VERSION="${FLINK_VERSION%.*}"
export FLINK_SERIES="${FLINK_VERSION%%.*}"

if [[ "$FLINK_SERIES" == "1" ]]; then
	if [[ "$FLINK_MAJOR_VERSION" != "1.20" && \
	      "$FLINK_MAJOR_VERSION" != "1.19" && \
	      "$FLINK_MAJOR_VERSION" != "1.18" && \
	      "$FLINK_MAJOR_VERSION" != "1.17" && \
	      "$FLINK_MAJOR_VERSION" != "1.16" && \
	      "$FLINK_MAJOR_VERSION" != "1.15" ]]; then
		m_exit "Flink version is not supported: $FLINK_VERSION"
	fi
else
        m_exit "Flink version is not supported: $FLINK_VERSION"
fi

export FLINK_TASKMANAGERS=$(( FLINK_TASKMANAGERS_PER_NODE * WORKERS_NUMBER ))
export FLINK_PARALLELISM=$(( FLINK_TASKMANAGERS * FLINK_TASKMANAGER_SLOTS ))

if [[ "${RESOURCE_MANAGER:-standalone}" == "yarn" ]]; then
	# Deploy mode
	export FINISH_YARN="false"
	# Session Mode
	export DEPLOY_ARGS="run -t yarn-session"
	export YARN_PROPS_FILE_CUSTOM="$TMP_DIR/.yarn-properties-$USER"
	export YARN_PROPS_FILE_DEFAULT="/tmp/.yarn-properties-$USER"
	export YARN_APP_ID=""

	_flink_jobmanager_memory="$FLINK_YARN_JOBMANAGER_MEMORY"
	_flink_taskmanager_memory="$FLINK_YARN_TASKMANAGER_MEMORY"

else
	# Deploy mode
	export FINISH_YARN="true"
	# Session Mode
	export DEPLOY_ARGS="run -p ${FLINK_PARALLELISM}"

	_flink_jobmanager_memory="$FLINK_JOBMANAGER_MEMORY"
	_flink_taskmanager_memory="$FLINK_TASKMANAGER_MEMORY"
fi

# Hadoop integration
export HADOOP_HOME="$FLINK_HADOOP_HOME"
. "$COMMON_HADOOP_DIR/etc/env.sh"

add_conf_param "flink_conf_dir"			"$FLINK_CONF_DIR"
add_conf_param "flink_log_dir"			"$FLINK_LOG_DIR"
add_conf_param "flink_default_parallelism"	"$FLINK_PARALLELISM"
add_conf_param "flink_jobmanager_memory"	"$_flink_jobmanager_memory"
add_conf_param "flink_taskmanager_memory"	"$_flink_taskmanager_memory"
