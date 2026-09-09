#!/bin/bash

export FRAMEWORK_TEMPLATE_DIR="$TEMPLATES_DIR/Spark"
export FRAMEWORK_CONF_DIR_SRC="$FRAMEWORK_HOME/conf"
export FRAMEWORK_CONF_DIR="$FRAMEWORK_REPORT_DIR/conf/spark"
export FRAMEWORK_LOG_DIR="$FRAMEWORK_REPORT_DIR/logs/spark"
export FRAMEWORK_LIB_DIR="$FRAMEWORK_REPORT_DIR/lib/spark"
export FRAMEWORK_BENCH_DIR="$BENCHMARKS_DIR/Spark"
export MASTERFILE="$FRAMEWORK_CONF_DIR/masters"
export WORKERSFILE="$FRAMEWORK_CONF_DIR/workers"

#SPARK
export SPARK_HOME="$FRAMEWORK_HOME"
export SPARK_CONF_DIR="$FRAMEWORK_CONF_DIR"
export SPARK_LOG_DIR="$FRAMEWORK_LOG_DIR"
export SPARK_LIB_DIR="$FRAMEWORK_LIB_DIR"
export SPARK_WORKER_DIR="$FRAMEWORK_LOG_DIR/worker"
export PATH="$SPARK_HOME/bin:$PATH"
export SPARK_SSH_OPTS="${BDEV_SSH_OPTS}"
export SPARK_VERSION="${FRAMEWORK_HOME##*/}"
export SPARK_MAJOR_VERSION="${SPARK_VERSION%.*}"
export SPARK_SERIES="${SPARK_VERSION%%.*}"

if [[ "$SPARK_SERIES" == "0" || "$SPARK_SERIES" == "1" ]]; then
	m_exit "Spark version is not supported: $SPARK_VERSION"
fi

if [[ "${RESOURCE_MANAGER:-standalone}" == "yarn" ]]; then
	#Deploy mode
	export FINISH_YARN="false"
	# YARN client mode
	export DEPLOY_ARGS="--master yarn --deploy-mode client \
		--conf spark.hadoop.yarn.timeline-service.enabled=false"

	export SPARK_EXECUTORS=$(( SPARK_YARN_EXECUTORS_PER_NODE * WORKERS_NUMBER ))

	_spark_executor_cores="$SPARK_YARN_CORES_PER_EXECUTOR"
	_spark_executor_memory="$SPARK_YARN_EXECUTOR_HEAPSIZE"
	_spark_executor_overhead="$SPARK_YARN_EXECUTOR_MEMORY_OVERHEAD"

else
	#Deploy mode
	export FINISH_YARN="true"
	export DEPLOY_ARGS="--master spark://${MASTERNODE}:7077 --deploy-mode client"
	
	export SPARK_EXECUTORS=$((($SPARK_WORKERS_PER_NODE * $WORKERS_NUMBER) * $SPARK_EXECUTORS_PER_WORKER))

	_spark_executor_cores="$SPARK_CORES_PER_EXECUTOR"
	_spark_executor_memory="$SPARK_EXECUTOR_HEAPSIZE"
	_spark_executor_overhead="$SPARK_EXECUTOR_MEMORY_OVERHEAD"
fi

	
export SPARK_DEFAULT_PARALLELISM=$(($SPARK_EXECUTORS * _spark_executor_cores))
export SPARK_SQL_SHUFFLE_PARTITIONS=$(($SPARK_DEFAULT_PARALLELISM * $SPARK_SQL_SHUFFLE_PARTITIONS_PER_CORE))

# Hadoop integration
export HADOOP_HOME="$SPARK_HADOOP_HOME"
. "$COMMON_HADOOP_DIR/etc/env.sh"

add_conf_param "spark_conf_dir"			"$SPARK_CONF_DIR"
add_conf_param "spark_log_dir"			"$SPARK_LOG_DIR"
add_conf_param "spark_worker_dir"		"$SPARK_WORKER_DIR"
add_conf_param "spark_executor_instances"	"$SPARK_EXECUTORS"
add_conf_param "spark_executor_memory"		"$_spark_executor_memory"
add_conf_param "spark_executor_cores"		"$_spark_executor_cores"
add_conf_param "spark_executor_memOverhead"	"$_spark_executor_overhead"
add_conf_param "spark_default_parallelism"	"$SPARK_DEFAULT_PARALLELISM"
add_conf_param "spark_sql_shuffle_partitions"	"$SPARK_SQL_SHUFFLE_PARTITIONS"
