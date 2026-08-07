#!/bin/bash

if [[ $FORCE_FORMAT_HDFS == "true" ]]; then
	#Format HDFS
	HDFS_FORMAT_LOG=$SOLUTION_REPORT_DIR/hdfs-format.log
	m_echo "Formatting HDFS, logging to $HDFS_FORMAT_LOG"
	$SSH_CMD $MASTERNODE "$HDFS_CONFIG $HADOOP_CONF_DIR namenode -format -force -clusterID CID-bdev" > $HDFS_FORMAT_LOG 2>&1
fi

#Namenode & Datanodes
$SSH_CMD $MASTERNODE "$HDFS_CONFIG $HADOOP_CONF_DIR --daemon start namenode"

if [[ $SECONDARY_NAMENODE == "true" ]]
then
	#Secondary NameNode
	$SSH_CMD $MASTERNODE "$HDFS_CONFIG $HADOOP_CONF_DIR --daemon start secondarynamenode"
fi

$HADOOP_HOME/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode

#Resourcemanager & Nodemanagers
$SSH_CMD $MASTERNODE "$YARN_CONFIG $HADOOP_CONF_DIR --daemon start resourcemanager"
$HADOOP_HOME/sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR start nodemanager

if [[ $TIMELINE_SERVER == "true" ]]
then
    #YARN Timeline server
    $SSH_CMD $MASTERNODE "$YARN_CONFIG $HADOOP_CONF_DIR --daemon start timelineserver"
fi

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	#MapReduce history server
	$SSH_CMD $MASTERNODE "$HADOOP_HOME/bin/mapred --config $HADOOP_CONF_DIR --daemon start historyserver"
fi
