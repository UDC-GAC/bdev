#!/bin/bash

# Copy YARN scheduler configuration
cp $EXP_DIR/*-scheduler.xml $HADOOP_CONF_DIR

if [[ $HADOOP_SERIES == "3" ]]
then
	$COMMON_SRC_DIR/bin/start_hadoop_yarn_3.sh
else
	$COMMON_SRC_DIR/bin/start_hadoop_yarn_2.sh
fi

if [[ $NAMENODE_SAFEMODE_TIMEOUT -ge 15 ]]
then
	sleep $NAMENODE_SAFEMODE_TIMEOUT
else
	sleep 15
fi
