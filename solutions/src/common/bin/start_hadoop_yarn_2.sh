#!/bin/bash

if [[ $FORCE_FORMAT_HDFS == "true" ]]; then
	#Format HDFS
	HDFS_FORMAT_LOG=$SOLUTION_REPORT_DIR/hdfs-format.log
	m_echo "Formatting HDFS, logging to $HDFS_FORMAT_LOG"
	$SSH_CMD $MASTERNODE "$HDFS_CONFIG $HADOOP_CONF_DIR namenode -format -force -clusterID CID-bdev" > $HDFS_FORMAT_LOG 2>&1
fi

#Namenode & Datanodes
$SSH_CMD $MASTERNODE "$HADOOP_HOME/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode" &
$HADOOP_HOME/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode &

#Resourcemanager & Nodemanagers
$SSH_CMD $MASTERNODE "$HADOOP_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start resourcemanager" &
$HADOOP_HOME/sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR start nodemanager &

if [[ $TIMELINE_SERVER == "true" ]]
then
        #YARN Timeline server
	$SSH_CMD $MASTERNODE "$HADOOP_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start timelineserver" &
fi

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	#MapReduce history server
	$SSH_CMD $MASTERNODE "$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver" &
fi
