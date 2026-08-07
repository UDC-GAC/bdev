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
export SPARK_MAJOR_VERSION=`echo $SOLUTION_VERSION | awk 'BEGIN{FS=OFS="."} NF--'`
export SPARK_SERIES=`echo ${SPARK_MAJOR_VERSION} | cut -d '.' -f 1`

if [[ $SPARK_SERIES == "0" ]] || [[ $SPARK_SERIES == "1" ]]
	m_exit "Spark version is not supported: $SPARK_MAJOR_VERSION"
fi

#YARN environment variables
export HADOOP_HOME=$SPARK_HADOOP_HOME
export HADOOP_CONF_DIR_SRC=$HADOOP_HOME/etc/hadoop
export HADOOP_CONF_DIR=$SOLUTION_REPORT_DIR/conf/hadoop
export HADOOP_LOG_DIR=$SOLUTION_REPORT_DIR/logs/hadoop
export YARN_CONF_DIR=$HADOOP_CONF_DIR
export YARN_LOG_DIR=$SOLUTION_REPORT_DIR/logs/hadoop
export PATH=$HADOOP_HOME/bin:$PATH

export HADOOP_SERIES=`echo ${HADOOP_HOME##*/} | cut -d '.' -f 1`

if [[ $HADOOP_SERIES == "3" ]]
then
	export HADOOP_TEMPLATE_DIR=$TEMPLATES_DIR/Hadoop-YARN-3
	export HADOOP_SGE_DAEMONS_DIR=$SGE_DAEMONS_DIR/Hadoop-YARN-3
	export HADOOP_STD_DAEMONS_DIR=$STD_DAEMONS_DIR/Hadoop-YARN-3
	export HADOOP_SBIN_DIR=$HADOOP_HOME/libexec
	export HADOOP_SLAVESFILE=$HADOOP_CONF_DIR/workers
else
	export HADOOP_TEMPLATE_DIR=$TEMPLATES_DIR/Hadoop-YARN
	export HADOOP_SGE_DAEMONS_DIR=$SGE_DAEMONS_DIR/Hadoop-YARN
	export HADOOP_STD_DAEMONS_DIR=$STD_DAEMONS_DIR/Hadoop-YARN
	export HADOOP_SBIN_DIR=$HADOOP_HOME/sbin
	export HADOOP_SLAVESFILE=$HADOOP_CONF_DIR/slaves
fi

export HADOOP_MR_VERSION="YARN"

#Configuracion
export OLD_GEN_CONFIG_SCRIPT=$GEN_CONFIG_SCRIPT
export GEN_CONFIG_SCRIPT=$SOLUTION_DIR/bin/gen-config.sh

#Deploy mode
export FINISH_YARN="false"
# YARN client mode
export DEPLOY_ARGS="--master yarn --deploy-mode client \
	--conf spark.hadoop.yarn.timeline-service.enabled=false"

if [[ $SPARK_SERIES == "0" ]] || [[ $SPARK_SERIES == "1" ]]
	m_exit "Spark version is not supported: $SPARK_MAJOR_VERSION"
else if [[ $SPARK_SERIES == "2" ]]
	SPARK_WORKERS_START_SCRIPT=$SPARK_HOME/sbin/start-slaves.sh
else
	SPARK_WORKERS_START_SCRIPT=$SPARK_HOME/sbin/start-workers.sh
fi

add_conf_param "spark_conf_dir" $SPARK_CONF_DIR
add_conf_param "spark_log_dir" $SPARK_LOG_DIR
add_conf_param "spark_worker_dir" $SPARK_WORKER_DIR
add_conf_param "spark_executor_instances" $SPARK_EXECUTORS
add_conf_param "spark_executor_memory" $SPARK_YARN_EXECUTOR_HEAPSIZE
add_conf_param "spark_executor_cores" $SPARK_YARN_CORES_PER_EXECUTOR
add_conf_param "spark_executor_memOverhead" $SPARK_YARN_EXECUTOR_MEMORY_OVERHEAD
add_conf_param "spark_default_parallelism" $SPARK_DEFAULT_PARALLELISM
add_conf_param "spark_sql_shuffle_partitions" $SPARK_SQL_SHUFFLE_PARTITIONS
