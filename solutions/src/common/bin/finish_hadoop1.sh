#!/bin/bash

for slave in $SLAVENODES
do
	m_echo "Finishing TaskTracker:" $slave
	ssh $slave ' for p in $(jps | grep TaskTracker | tr -s " " | cut -d " " -f 1);
	do echo $p; kill -9 $p; done' >& /dev/null
done

m_echo "Finishing JobTracker:" $MASTERNODE
ssh $MASTERNODE ' for p in $(jps | grep JobTracker | tr -s " " | cut -d " " -f 1);
	do echo $p; kill -9 $p; done' >& /dev/null

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	m_echo "Finishing JobHistoryServer:" $MASTERNODE
	ssh $MASTERNODE ' for p in $(jps | grep JobHistoryServer | tr -s " " | cut -d " " -f 1);
        	do echo $p; kill -9 $p; done' >& /dev/null
fi

sleep 1
