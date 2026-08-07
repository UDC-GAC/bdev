#!/bin/sh
export SOL_BENCH_DIR=$SOLUTIONS_BENCH_DIR/Spark
export SOL_TEMPLATE_DIR=$TEMPLATES_DIR/Spark
export SOL_SBIN_DIR=$SOLUTION_HOME/sbin
export SOL_CONF_DIR_SRC=$SOLUTION_HOME/conf
export SOL_CONF_DIR=$SOLUTION_REPORT_DIR/conf/spark
export SOL_LOG_DIR=$SOLUTION_REPORT_DIR/logs/spark
export MASTERFILE=$SOL_CONF_DIR/masters
export SLAVESFILE=$SOL_CONF_DIR/slaves

#SPARK
export SPARK_HOME=$SOLUTION_HOME
export SPARK_CONF_DIR=$SOL_CONF_DIR
export SPARK_SBIN_DIR=$SOL_SBIN_DIR
export SPARK_LOG_DIR=$SOL_LOG_DIR
export SPARK_WORKER_DIR=$SOLUTION_REPORT_DIR/logs/spark/work
export SPARK_EXECUTORS=$(($SPARK_YARN_EXECUTORS_PER_NODE * $SLAVES_NUMBER))
export SPARK_DEFAULT_PARALLELISM=$(($SPARK_EXECUTORS * $SPARK_YARN_CORES_PER_EXECUTOR))
export SPARK_SQL_SHUFFLE_PARTITIONS=$(($SPARK_DEFAULT_PARALLELISM * $SPARK_SQL_SHUFFLE_PARTITIONS_PER_CORE))
export PATH=$SPARK_HOME/bin:$PATH
export SPARK_VERSION=${SOLUTION_HOME##*/}
export SPARK_MAJOR_VERSION=${SPARK_VERSION%.*}
export SPARK_SERIES=${SPARK_VERSION%%.*}

if [[ $SPARK_SERIES == "0" ]] || [[ $SPARK_SERIES == "1" ]]; then
	m_exit "Spark version is not supported: $SPARK_VERSION"
fi

#YARN environment variables
export HADOOP_HOME=$SPARK_HADOOP_HOME
export HADOOP_CONF_DIR_SRC=$HADOOP_HOME/etc/hadoop
export HADOOP_CONF_DIR=$SOLUTION_REPORT_DIR/conf/hadoop
export HADOOP_LOG_DIR=$SOLUTION_REPORT_DIR/logs/hadoop
export YARN_CONF_DIR=$HADOOP_CONF_DIR
export YARN_LOG_DIR=$SOLUTION_REPORT_DIR/logs/hadoop
export PATH=$HADOOP_HOME/bin:$PATH
export HADOOP_VERSION=${HADOOP_HOME##*/}
export HADOOP_MAJOR_VERSION=${HADOOP_VERSION%.*}
export HADOOP_SERIES=${HADOOP_VERSION%%.*}

if [[ $HADOOP_SERIES == "3" ]]; then
	export SOL_TEMPLATE_DIR=$TEMPLATES_DIR/Hadoop-YARN-3
	export SOL_DAEMONS_DIR=$DAEMONS_DIR/Hadoop-YARN-3
	export SOL_SBIN_DIR=$SOLUTION_HOME/libexec
	export SLAVESFILE=$SOL_CONF_DIR/workers
elif [[ $HADOOP_SERIES == "2" ]]; then
	export SOL_TEMPLATE_DIR=$TEMPLATES_DIR/Hadoop-YARN
	export SOL_DAEMONS_DIR=$DAEMONS_DIR/Hadoop-YARN
	export SOL_SBIN_DIR=$SOLUTION_HOME/sbin
	export SLAVESFILE=$SOL_CONF_DIR/slaves
else
	m_exit "Hadoop version is not supported: $HADOOP_VERSION"
fi

#Configuration
export OLD_GEN_CONFIG_SCRIPT=$GEN_CONFIG_SCRIPT
export GEN_CONFIG_SCRIPT=$SOLUTION_DIR/bin/gen-config.sh

#Deploy mode
export FINISH_YARN="false"
# YARN client mode
export DEPLOY_ARGS="--master yarn --deploy-mode client \
	--conf spark.hadoop.yarn.timeline-service.enabled=false"

add_conf_param "spark_conf_dir" $SPARK_CONF_DIR
add_conf_param "spark_log_dir" $SPARK_LOG_DIR
add_conf_param "spark_worker_dir" $SPARK_WORKER_DIR
add_conf_param "spark_executor_instances" $SPARK_EXECUTORS
add_conf_param "spark_executor_memory" $SPARK_YARN_EXECUTOR_HEAPSIZE
add_conf_param "spark_executor_cores" $SPARK_YARN_CORES_PER_EXECUTOR
add_conf_param "spark_executor_memOverhead" $SPARK_YARN_EXECUTOR_MEMORY_OVERHEAD
add_conf_param "spark_default_parallelism" $SPARK_DEFAULT_PARALLELISM
add_conf_param "spark_sql_shuffle_partitions" $SPARK_SQL_SHUFFLE_PARTITIONS
