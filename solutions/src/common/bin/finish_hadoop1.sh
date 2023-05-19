#!/bin/bash

SLAVES=`cat $SLAVESFILE`
for slave in $SLAVES
do
	m_echo "Finishing TaskTracker:" $slave
	$SSH_CMD $slave "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS TaskTracker"
done

m_echo "Finishing JobTracker:" $MASTERNODE
$SSH_CMD $MASTERNODE "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS JobTracker"

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	m_echo "Finishing JobHistoryServer:" $MASTERNODE
	$SSH_CMD $MASTERNODE "${LOAD_JAVA_COMMAND}; ${METHOD_BIN_DIR}/kill.sh $JPS JobHistoryServer"
fi

sleep 1
