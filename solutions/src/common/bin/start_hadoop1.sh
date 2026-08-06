#!/bin/bash

if [[ $FORCE_FORMAT_HDFS == "true" ]]; then
	#Format HDFS
	HDFS_FORMAT_LOG=$SOLUTION_REPORT_DIR/hdfs-format.log
	m_echo "Formatting HDFS, logging to $HDFS_FORMAT_LOG"
	$SSH_CMD $MASTERNODE "$HDFS_CONFIG $HADOOP_CONF_DIR namenode -format -force -clusterID CID-bdev" > $HDFS_FORMAT_LOG 2>&1
fi

#Namenode & Datanodes
$SSH_CMD $MASTERNODE "$HADOOP_HOME/bin/hadoop-daemon.sh --config $HADOOP_CONF_DIR start namenode" &
$HADOOP_HOME/bin/hadoop-daemons.sh --config $HADOOP_CONF_DIR start datanode &

sleep 5

#Jobtracker & Tasktrackers
$SSH_CMD $MASTERNODE "$HADOOP_HOME/bin/hadoop-daemon.sh --config $HADOOP_CONF_DIR start jobtracker" &
$HADOOP_HOME/bin/hadoop-daemons.sh --config $HADOOP_CONF_DIR start tasktracker &

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	#MapReduce Jobhistory server
	$SSH_CMD $MASTERNODE "$HADOOP_HOME/bin/hadoop-daemon.sh --config $HADOOP_CONF_DIR start historyserver" &
fi

sleep 5

SAFEMODE_STATUS=$($HADOOP_HOME/bin/hdfs dfsadmin -safemode get 2>/dev/null)

if [[ "$SAFEMODE_STATUS" == *"ON"* ]]; then
    m_echo "HDFS is in Safe Mode. Waiting for DataNodes..."
    $HADOOP_HOME/bin/hdfs dfsadmin -safemode wait >/dev/null 2>&1
    m_echo "HDFS has exited the Safe Mode and is ready for writing"
fi
