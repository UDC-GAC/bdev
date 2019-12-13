#!/bin/bash

#Format HDFS
ssh $MASTERNODE $HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR namenode -format

#Namenode & Datanodes
ssh $MASTERNODE "$HADOOP_HOME/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode" &
$HADOOP_HOME/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode &

#Resourcemanager & Nodemanagers
ssh $MASTERNODE "$HADOOP_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start resourcemanager" &
$HADOOP_HOME/sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR start nodemanager &

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	#MapReduce history server
	ssh $MASTERNODE "$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver" &
fi