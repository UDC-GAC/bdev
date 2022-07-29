#!/bin/bash

SLAVES=`cat $SLAVESFILE`
for slave in $SLAVES
do
	m_echo "Finishing DataNode:" $slave
        ssh $slave "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS DataNode"
done

m_echo "Finishing NameNode:" $MASTERNODE
ssh $MASTERNODE "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS NameNode"

sleep 1
