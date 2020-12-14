#!/bin/bash

for slave in $SLAVENODES
do
	m_echo "Finishing NodeManager:" $slave
        ssh $slave "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS NodeManager"
done

m_echo "Finishing ResourceManager:" $MASTERNODE
ssh $MASTERNODE "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS ResourceManager"

if [[ $TIMELINE_SERVER == "true" ]]
then
	m_echo "Finishing ApplicationHistoryServer:" $MASTERNODE
	ssh $MASTERNODE "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS ApplicationHistoryServer"
fi

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	m_echo "Finishing JobHistoryServer:" $MASTERNODE
	ssh $MASTERNODE "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS JobHistoryServer"
fi

sleep 1
