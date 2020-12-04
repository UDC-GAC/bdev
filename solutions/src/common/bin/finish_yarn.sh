#!/bin/bash

for slave in $SLAVENODES
do
        m_echo "Finishing NodeManager:" $slave
        ssh $slave ${LOAD_JAVA_COMMAND}; for p in $(${JPS} | grep NodeManager | tr -s " " | cut -d " " -f 1);
        do echo $p; kill -9 $p; done" >& /dev/null
done

m_echo "Finishing ResourceManager:" $MASTERNODE
ssh $MASTERNODE "${LOAD_JAVA_COMMAND}; for p in $(${JPS} | grep ResourceManager | tr -s " " | cut -d " " -f 1);
        do echo $p; kill -9 $p; done" >& /dev/null

if [[ $TIMELINE_SERVER == "true" ]]
then
	m_echo "Finishing ApplicationHistoryServer:" $MASTERNODE
	ssh $MASTERNODE "${LOAD_JAVA_COMMAND}; for p in $(${JPS} | grep ApplicationHistoryServer | tr -s " " | cut -d " " -f 1);
        	do echo $p; kill -9 $p; done" >& /dev/null
fi

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	m_echo "Finishing JobHistoryServer:" $MASTERNODE
	ssh $MASTERNODE "${LOAD_JAVA_COMMAND}; for p in $(${JPS} | grep JobHistoryServer | tr -s " " | cut -d " " -f 1);
        	do echo $p; kill -9 $p; done" >& /dev/null
fi

sleep 1
