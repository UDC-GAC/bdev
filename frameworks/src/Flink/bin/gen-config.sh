#!/bin/bash

m_echo "Flink configuration"
. $OLD_GEN_CONFIG_SCRIPT

if [[ "$FLINK_TASKMANAGERS_PER_NODE" -gt 1 ]]; then
	NODES=$(cat $WORKERSFILE)
	rm -f "$WORKERSFILE"
	for NODE in $NODES; do
		i=1
		while [[ "$i" -le "$FLINK_TASKMANAGERS_PER_NODE" ]]; do
			echo $NODE >> $WORKERSFILE
			i=$((i + 1))
		done
	done
fi

export SOL_TEMPLATE_DIR=$HADOOP_TEMPLATE_DIR
export SOL_CONF_DIR=$HADOOP_CONF_DIR
export MASTERFILE=$HADOOP_CONF_DIR/masters
export WORKERSFILE=$HADOOP_WORKERSFILE

m_echo "Hadoop configuration: $FLINK_HADOOP_HOME"
. $OLD_GEN_CONFIG_SCRIPT
