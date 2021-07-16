#!/bin/bash

SLAVES=`cat $SLAVESFILE`
for slave in $SLAVES
do
	m_echo "Finishing TaskTracker:" $slave
	ssh $slave "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS TaskTracker"
done

m_echo "Finishing JobTracker:" $MASTERNODE
ssh $MASTERNODE "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS JobTracker"

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	m_echo "Finishing JobHistoryServer:" $MASTERNODE
	ssh $MASTERNODE "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS JobHistoryServer"
fi

sleep 1
