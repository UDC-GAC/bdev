#!/bin/bash
export SOL_BENCH_DIR=$BENCHMARKS_DIR/Spark
export SOL_TEMPLATE_DIR=$TEMPLATES_DIR/Spark
export SOL_SBIN_DIR=$SOLUTION_HOME/sbin
export SOL_CONF_DIR_SRC=$SOLUTION_HOME/conf
export SOL_CONF_DIR=$SOLUTION_REPORT_DIR/conf/spark
export SOL_LOG_DIR=$SOLUTION_REPORT_DIR/logs/spark
export MASTERFILE=$SOL_CONF_DIR/masters
export WORKERSFILE=$SOL_CONF_DIR/workers

#SPARK
export SPARK_HOME=$SOLUTION_HOME
export SPARK_CONF_DIR=$SOL_CONF_DIR
export SPARK_SBIN_DIR=$SOL_SBIN_DIR
export SPARK_LOG_DIR=$SOL_LOG_DIR
export SPARK_WORKER_DIR=$SOLUTION_REPORT_DIR/logs/spark/work
export SPARK_EXECUTORS=$((($SPARK_WORKERS_PER_NODE * $WORKERS_NUMBER) * $SPARK_EXECUTORS_PER_WORKER))
export SPARK_DEFAULT_PARALLELISM=$(($SPARK_EXECUTORS * $SPARK_CORES_PER_EXECUTOR))
export SPARK_SQL_SHUFFLE_PARTITIONS=$(($SPARK_DEFAULT_PARALLELISM * $SPARK_SQL_SHUFFLE_PARTITIONS_PER_CORE))
export PATH=$SPARK_HOME/bin:$PATH
export SPARK_VERSION=${SOLUTION_HOME##*/}
export SPARK_MAJOR_VERSION=${SPARK_VERSION%.*}
export SPARK_SERIES=${SPARK_VERSION%%.*}
export SPARK_SSH_OPTS="${BDEV_SSH_OPTS}"

if [ $SPARK_SERIES == "0" ] || [ $SPARK_SERIES == "1" ]; then
	m_exit "Spark version is not supported: $SPARK_VERSION"
fi

# Hadoop
export HADOOP_HOME=$SPARK_HADOOP_HOME
. $COMMON_SRC_DIR/etc/env.sh

#Configuration
export OLD_GEN_CONFIG_SCRIPT=$GEN_CONFIG_SCRIPT
export GEN_CONFIG_SCRIPT=$SOLUTION_DIR/bin/gen-config.sh

#Deploy mode
export FINISH_YARN="true"
export DEPLOY_ARGS="--master spark://${MASTERNODE}:7077 --deploy-mode client"

add_conf_param "spark_conf_dir" $SPARK_CONF_DIR
add_conf_param "spark_log_dir" $SPARK_LOG_DIR
add_conf_param "spark_worker_dir" $SPARK_WORKER_DIR
add_conf_param "spark_executor_instances" $SPARK_EXECUTORS
add_conf_param "spark_executor_memory" $SPARK_EXECUTOR_HEAPSIZE
add_conf_param "spark_executor_cores" $SPARK_CORES_PER_EXECUTOR
add_conf_param "spark_executor_memOverhead" $SPARK_EXECUTOR_MEMORY_OVERHEAD
add_conf_param "spark_default_parallelism" $SPARK_DEFAULT_PARALLELISM
add_conf_param "spark_sql_shuffle_partitions" $SPARK_SQL_SHUFFLE_PARTITIONS
