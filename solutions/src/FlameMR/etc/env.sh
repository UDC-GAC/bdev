#!/bin/sh

HADOOP_VERSION=`echo ${FLAMEMR_HADOOP_HOME##*/}`

export HADOOP_SERIES=`echo ${HADOOP_VERSION} | cut -d '.' -f 1`
HADOOP_SUBSERIES=`echo ${HADOOP_VERSION} | cut -d '.' -f 2`

if [[ "${HADOOP_SERIES}.${HADOOP_SUBSERIES}" == "2.7" ]]
then
	export SOLUTION_HOME="${SOLUTION_HOME}-2.7"
fi

export SOL_BENCH_DIR=$SOLUTIONS_BENCH_DIR/FlameMR
export SOL_CONF_DIR_SRC=$SOLUTION_HOME/conf
export SOL_CONF_DIR=$SOLUTION_REPORT_DIR/conf/flamemr
export SOL_LOG_DIR=$SOLUTION_REPORT_DIR/logs/flamemr
export SOL_TEMPLATE_DIR=$TEMPLATES_DIR/FlameMR
export MASTERFILE=$SOL_CONF_DIR/masters
export SLAVESFILE=$SOL_CONF_DIR/slaves

#FLAMEMR
export FLAMEMR_HOME=$SOLUTION_HOME
export FLAMEMR_CONF_DIR=$SOL_CONF_DIR
export PATH=$FLAMEMR_HOME/bin:$PATH

#YARN environment variables
export HADOOP_HOME=$FLAMEMR_HADOOP_HOME
export HADOOP_CONF_DIR_SRC=$HADOOP_HOME/etc/hadoop
export HADOOP_CONF_DIR=$SOLUTION_REPORT_DIR/conf/hadoop
export HADOOP_LOG_DIR=$SOLUTION_REPORT_DIR/logs/hadoop
export YARN_CONF_DIR=$HADOOP_CONF_DIR
export YARN_LOG_DIR=$SOLUTION_REPORT_DIR/logs/hadoop
export PATH=$HADOOP_HOME/bin:$PATH

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
export FINISH_YARN="false"

add_conf_param "flamemr_conf_dir" $FLAMEMR_CONF_DIR
add_conf_param "flamemr_worker_memory" $FLAMEMR_WORKER_MEMORY
add_conf_param "flamemr_worker_cores" $FLAMEMR_CORES_PER_WORKER
add_conf_param "flamemr_workers_per_node" $FLAMEMR_WORKERS_PER_NODE
add_conf_param "flamemr_buffer_size" $FLAMEMR_BUFFER_SIZE
add_conf_param "flamemr_debug_mode" $FLAMEMR_DEBUG_MODE
add_conf_param "flamemr_iterative_mode" $FLAMEMR_ITERATIVE_MODE
add_conf_param "flamemr_iterative_cache_input" $FLAMEMR_ITERATIVE_CACHE_INPUT
add_conf_param "flamemr_merge_outputs" $FLAMEMR_MERGE_OUTPUTS
add_conf_param "flamemr_load_balancing_mode" $FLAMEMR_LOAD_BALANCING_MODE
add_conf_param "flamemr_load_balancing_threshold" $FLAMEMR_LOAD_BALANCING_THRESHOLD
add_conf_param "flamemr_additional_conf" $FLAMEMR_ADDITIONAL_CONFIGURATION

