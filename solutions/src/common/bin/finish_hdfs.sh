#!/bin/bash

SLAVES=`cat $SLAVESFILE`
for slave in $SLAVES
do
	m_echo "Finishing DataNode:" $slave
        $SSH_CMD $slave "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS DataNode"
done

m_echo "Finishing NameNode:" $MASTERNODE
$SSH_CMD $MASTERNODE "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS NameNode"

sleep 1
