#!/bin/sh
m_echo "Flink configuration"
bash $OLD_GEN_CONFIG_SCRIPT

# Add here memory configuration for JobManager and Taskmanagers
echo "${FLINK_JOBMANAGER_MEMORY_PARAM}m" >> $FLINK_CONFIG_YAML_FILE
echo "${FLINK_TASKMANAGER_MEMORY_PARAM}m" >> $FLINK_CONFIG_YAML_FILE

if [[ $FLINK_TASKMANAGERS_PER_NODE -gt 1 ]]
then
	SLAVELIST=`cat $SLAVESFILE`
	rm $SLAVESFILE
	for slave in $SLAVELIST
	do
		for i in `seq 1 $FLINK_TASKMANAGERS_PER_NODE`
		do
			echo $slave >> $SLAVESFILE
		done
	done
	unset SLAVELIST
fi

export SOL_TEMPLATE_DIR=$HADOOP_TEMPLATE_DIR
export SOL_CONF_DIR_SRC=$HADOOP_CONF_DIR_SRC
export SOL_CONF_DIR=$HADOOP_CONF_DIR
export SOL_LOG_DIR=$HADOOP_LOG_DIR
export MASTERFILE=$HADOOP_CONF_DIR/masters
export SLAVESFILE=$HADOOP_SLAVESFILE

m_echo "Hadoop configuration: $FLINK_HADOOP_HOME"
bash $OLD_GEN_CONFIG_SCRIPT
