#!/bin/bash

#Format HDFS
HDFS_FORMAT_LOG=$SOLUTION_REPORT_DIR/hdfs-format.log
m_echo "Formatting HDFS, logging to $HDFS_FORMAT_LOG"
$SSH_CMD $MASTERNODE $HADOOP_HOME/bin/hadoop --config $HADOOP_CONF_DIR namenode -format > $HDFS_FORMAT_LOG 2>&1

#Namenode & Datanodes
$SSH_CMD $MASTERNODE "$HADOOP_HOME/bin/hadoop-daemon.sh --config $HADOOP_CONF_DIR start namenode" &
$HADOOP_HOME/bin/hadoop-daemons.sh --config $HADOOP_CONF_DIR start datanode &

sleep 10

#Jobtracker & Tasktrackers
$SSH_CMD $MASTERNODE "$HADOOP_HOME/bin/hadoop-daemon.sh --config $HADOOP_CONF_DIR start jobtracker" &
$HADOOP_HOME/bin/hadoop-daemons.sh --config $HADOOP_CONF_DIR start tasktracker &

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	#MapReduce Jobhistory server
	$SSH_CMD $MASTERNODE "$HADOOP_HOME/bin/hadoop-daemon.sh --config $HADOOP_CONF_DIR start historyserver" &
fi

sleep 10
