#!/bin/bash

#Format HDFS
ssh $MASTERNODE $HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR namenode -format

#Namenode & Datanodes
ssh $MASTERNODE "$HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR --daemon start namenode" &
for slave in $SLAVENODES
do
	ssh $slave "$HADOOP_HOME/bin/hdfs --config $HADOOP_CONF_DIR --daemon start datanode" &
done

#Resourcemanager & Nodemanagers
ssh $MASTERNODE " $HADOOP_HOME/bin/yarn --config $HADOOP_CONF_DIR --daemon start resourcemanager" &

for slave in $SLAVENODES
do
	ssh $slave "$HADOOP_HOME/bin/yarn --config $HADOOP_CONF_DIR --daemon start nodemanager" &
done

if [[ $TIMELINE_SERVER == "true" ]]
then
        #YARN Timeline server
        ssh $MASTERNODE "$HADOOP_HOME/bin/yarn --config $HADOOP_CONF_DIR --daemon start timelineserver" &
fi

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	#MapReduce history server
	ssh $MASTERNODE "$HADOOP_HOME/bin/mapred --config $HADOOP_CONF_DIR --daemon start historyserver" &
fi
