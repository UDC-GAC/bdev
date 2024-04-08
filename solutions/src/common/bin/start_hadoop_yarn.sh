#!/bin/bash

# Copy YARN scheduler configuration
cp $EXP_DIR/*-scheduler.xml $HADOOP_CONF_DIR

if [[ $HADOOP_SERIES == "3" ]]
then
	$COMMON_SRC_DIR/bin/start_hadoop_yarn_3.sh
else
	$COMMON_SRC_DIR/bin/start_hadoop_yarn_2.sh
fi

SLEEP=15

if [[ $NAMENODE_SAFEMODE_TIMEOUT -gt 15000 ]]
then
	SLEEP=$(($NAMENODE_SAFEMODE_TIMEOUT / 1000))
fi

sleep $SLEEP
