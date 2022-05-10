#!/bin/bash

#Format HDFS
HDFS_FORMAT_LOG=$SOLUTION_REPORT_DIR/hdfs-format.log
m_echo "HDFS format, logging to $HDFS_FORMAT_LOG"
ssh $MASTERNODE "$HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR namenode -format" > $HDFS_FORMAT_LOG 2>&1

SLAVES=`cat $SLAVESFILE`

#Namenode & Datanodes
m_echo "Starting NameNode:" $MASTERNODE
ssh $MASTERNODE "$HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR --daemon start namenode" &
for slave in $SLAVES
do
	m_echo "Starting DataNode:" $slave
	ssh $slave "$HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR --daemon start datanode" &
done

#Resourcemanager & Nodemanagers
m_echo "Starting ResourceManager:" $MASTERNODE
ssh $MASTERNODE " $HADOOP_HOME/bin/yarn --config $HADOOP_CONF_DIR --daemon start resourcemanager" &

for slave in $SLAVES
do
	m_echo "Starting NodeManager:" $slave
	ssh $slave "$HADOOP_HOME/bin/yarn --config $HADOOP_CONF_DIR --daemon start nodemanager" &
done

if [[ $TIMELINE_SERVER == "true" ]]
then
        #YARN Timeline server
	m_echo "Starting YARN Timeline server:" $MASTERNODE
        ssh $MASTERNODE "$HADOOP_HOME/bin/yarn --config $HADOOP_CONF_DIR --daemon start timelineserver" &
fi

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	#MapReduce history server
	m_echo "Starting MapReduce history server:" $MASTERNODE
	ssh $MASTERNODE "$HADOOP_HOME/bin/mapred --config $HADOOP_CONF_DIR --daemon start historyserver" &
fi
