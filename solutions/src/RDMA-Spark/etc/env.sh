#!/bin/sh
export SOL_BENCH_DIR=$SOLUTIONS_BENCH_DIR/Spark
export SOL_TEMPLATE_DIR=$TEMPLATES_DIR/RDMA-Spark
export SOL_SGE_DAEMONS_DIR=$SGE_DAEMONS_DIR/Spark
export SOL_STD_DAEMONS_DIR=$STD_DAEMONS_DIR/Spark
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
export SPARK_EXECUTORS=$((($SPARK_WORKERS_PER_NODE * $SLAVES_NUMBER) * $SPARK_EXECUTORS_PER_WORKER))
export SPARK_DEFAULT_PARALLELISM=$(($SPARK_EXECUTORS * $SPARK_CORES_PER_EXECUTOR))
export SPARK_EXTRA_LIBRARY_PATH="$SPARK_HOME/lib/native/Linux-amd64-64"
export PATH=$SPARK_HOME/bin:$PATH
export SPARK_MAJOR_VERSION=`echo $SOLUTION_VERSION | awk 'BEGIN{FS=OFS="."} NF--'`
export SPARK_SERIES=`echo ${SPARK_MAJOR_VERSION} | cut -d '.' -f 1`

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
	if [[ "$SGE_ENV" == "true" ]]
	then
		export HADOOP_SSH_OPTS=" "
	fi
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

#Daemons
export OLD_COPY_DAEMONS_SCRIPT=$COPY_DAEMONS_SCRIPT
export COPY_DAEMONS_SCRIPT=$SOLUTION_DIR/bin/copy-daemons.sh

#Deploy mode
export FINISH_YARN="true"
export DEPLOY_ARGS="--master spark://${MASTERNODE}:7077 --deploy-mode client"

add_conf_param "spark_conf_dir" $SPARK_CONF_DIR
add_conf_param "spark_log_dir" $SPARK_LOG_DIR
add_conf_param "spark_worker_dir" $SPARK_WORKER_DIR
add_conf_param "spark_executor_instances" $SPARK_EXECUTORS
add_conf_param "spark_default_parallelism" $SPARK_DEFAULT_PARALLELISM
add_conf_param "spark_sql_shuffle_partitions" $SPARK_DEFAULT_PARALLELISM

add_conf_param "spark_executor_memory" $SPARK_EXECUTOR_HEAPSIZE
add_conf_param "spark_yarn_executor_memory" $SPARK_YARN_EXECUTOR_HEAPSIZE
add_conf_param "spark_executor_cores" $SPARK_YARN_CORES_PER_EXECUTOR

add_conf_param "spark_extra_library_path" $SPARK_EXTRA_LIBRARY_PATH

