#!/bin/sh
export SOL_BENCH_DIR=$SOLUTIONS_BENCH_DIR/Flink
export SOL_TEMPLATE_DIR=$TEMPLATES_DIR/Flink
export SOL_SGE_DAEMONS_DIR=$SGE_DAEMONS_DIR/Flink
export SOL_STD_DAEMONS_DIR=$STD_DAEMONS_DIR/Flink
export SOL_SBIN_DIR=$SOLUTION_HOME/bin
export SOL_CONF_DIR_SRC=$SOLUTION_HOME/conf
export SOL_CONF_DIR=$SOLUTION_REPORT_DIR/conf/flink
export SOL_LOG_DIR=$SOLUTION_REPORT_DIR/logs/flink
export MASTERFILE=$SOL_CONF_DIR/masters
export SLAVESFILE=$SOL_CONF_DIR/workers

#FLINK
export FLINK_HOME=$SOLUTION_HOME
export FLINK_CONF_DIR=$SOL_CONF_DIR
export FLINK_SBIN_DIR=$SOL_SBIN_DIR
export FLINK_LOG_DIR=$SOL_LOG_DIR
export PATH=$FLINK_HOME/bin:$PATH
export FLINK_TASKMANAGERS=$(($FLINK_TASKMANAGERS_PER_NODE * $SLAVES_NUMBER))
export FLINK_PARALLELISM=$(($FLINK_TASKMANAGERS * $FLINK_TASKMANAGER_SLOTS))
export FLINK_MAJOR_VERSION=`echo $SOLUTION_VERSION | awk 'BEGIN{FS=OFS="."} NF--'`
export FLINK_SERIES=`echo ${FLINK_MAJOR_VERSION} | cut -d '.' -f 1`
export FLINK_CONFIG_YAML_FILE=$SOL_CONF_DIR/flink-conf.yaml
export FLINK_HADOOP_CLASSPATH=$SOL_CONF_DIR/classpath

#YARN environment variables
export HADOOP_HOME=$FLINK_HADOOP_HOME
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
export DEPLOY_ARGS="-p ${FLINK_PARALLELISM}"

if [[ $FLINK_SERIES == "1" ]]
then
	if [[ $FLINK_MAJOR_VERSION != "1.19" ]] &&
		[[ $FLINK_MAJOR_VERSION != "1.18" ]] &&
		[[ $FLINK_MAJOR_VERSION != "1.17" ]] &&
		[[ $FLINK_MAJOR_VERSION != "1.16" ]] &&
		[[ $FLINK_MAJOR_VERSION != "1.15" ]] &&
		[[ $FLINK_MAJOR_VERSION != "1.14" ]] &&
		[[ $FLINK_MAJOR_VERSION != "1.13" ]]
	then
		m_exit "Flink version is not supported: $FLINK_MAJOR_VERSION"
	fi
	
	export FLINK_JOBMANAGER_MEMORY_PARAM="jobmanager.memory.process.size: $FLINK_JOBMANAGER_MEMORY"
	export FLINK_TASKMANAGER_MEMORY_PARAM="taskmanager.memory.process.size: $FLINK_TASKMANAGER_MEMORY"
else
	m_exit "Flink version is not supported: $FLINK_MAJOR_VERSION"
fi

# Copy config.sh file according to Flink version
if [[ "$SGE_ENV" == "true" ]]
then
	FLINK_CONFIG_SH_FILE=$SOL_SGE_DAEMONS_DIR/config/config-${FLINK_MAJOR_VERSION}.sh
else
	FLINK_CONFIG_SH_FILE=$SOL_STD_DAEMONS_DIR/config/config-${FLINK_MAJOR_VERSION}.sh
fi

if [ ! -f $FLINK_CONFIG_SH_FILE ]; then
        m_exit "Flink config.sh file not found: $FLINK_CONFIG_SH_FILE"
else
	m_echo "Copying Flink config.sh file: $FLINK_CONFIG_SH_FILE"
	cp -f $FLINK_CONFIG_SH_FILE $SOL_SBIN_DIR/config.sh
fi

add_conf_param "flink_conf_dir" $FLINK_CONF_DIR
add_conf_param "flink_log_dir" $FLINK_LOG_DIR
add_conf_param "flink_default_parallelism" $FLINK_PARALLELISM

