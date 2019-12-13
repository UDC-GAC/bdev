#!/bin/bash

#Format HDFS
ssh $MASTERNODE $HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR namenode -format 

#Namenode & Datanodes
ssh $MASTERNODE "$HADOOP_HOME/bin/hadoop-daemon.sh --config $HADOOP_CONF_DIR start namenode" &
$HADOOP_HOME/bin/hadoop-daemons.sh --config $HADOOP_CONF_DIR start datanode &

sleep 10

#Jobtracker & Tasktrackers
ssh $MASTERNODE "$HADOOP_HOME/bin/hadoop-daemon.sh --config $HADOOP_CONF_DIR start jobtracker" &
$HADOOP_HOME/bin/hadoop-daemons.sh --config $HADOOP_CONF_DIR start tasktracker &

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	#MapReduce Jobhistory server
	ssh $MASTERNODE "$HADOOP_HOME/bin/hadoop-daemon.sh --config $HADOOP_CONF_DIR start historyserver" &
fi

sleep 10
