#!/bin/bash

if [[ $FORCE_FORMAT_HDFS == "true" ]]; then
	#Format HDFS
	HDFS_FORMAT_LOG=$SOLUTION_REPORT_DIR/hdfs-format.log
	m_echo "Formatting HDFS, logging to $HDFS_FORMAT_LOG"
	$SSH_CMD $MASTERNODE "$HDFS_CONFIG $HADOOP_CONF_DIR namenode -format -force -clusterID CID-bdev" > $HDFS_FORMAT_LOG 2>&1
fi

SLAVES=`cat $SLAVESFILE`

#Namenode & Datanodes
m_echo "Starting NameNode:" $MASTERNODE
$SSH_CMD $MASTERNODE "$HDFS_CONFIG $HADOOP_CONF_DIR --daemon start namenode" &
for slave in $SLAVES
do
	m_echo "Starting DataNode:" $slave
	$SSH_CMD $slave "$HDFS_CONFIG $HADOOP_CONF_DIR --daemon start datanode" &
done

#Resourcemanager & Nodemanagers
m_echo "Starting ResourceManager:" $MASTERNODE
$SSH_CMD $MASTERNODE "$YARN_CONFIG $HADOOP_CONF_DIR --daemon start resourcemanager" &

for slave in $SLAVES
do
	m_echo "Starting NodeManager:" $slave
	$SSH_CMD $slave "$YARN_CONFIG $HADOOP_CONF_DIR --daemon start nodemanager" &
done

if [[ $TIMELINE_SERVER == "true" ]]
then
        #YARN Timeline server
	m_echo "Starting YARN Timeline server:" $MASTERNODE
        $SSH_CMD $MASTERNODE "$YARN_CONFIG $HADOOP_CONF_DIR --daemon start timelineserver" &
fi

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	#MapReduce history server
	m_echo "Starting MapReduce history server:" $MASTERNODE
	$SSH_CMD $MASTERNODE "$HADOOP_HOME/bin/mapred --config $HADOOP_CONF_DIR --daemon start historyserver" &
fi
