#!/bin/bash

for slave in $SLAVENODES
do
        m_echo "Finishing NodeManager:" $slave
        ssh $slave 'for p in $(jps | grep NodeManager | tr -s " " | cut -d " " -f 1);
        do echo $p; kill -9 $p; done' >& /dev/null
done

m_echo "Finishing ResourceManager:" $MASTERNODE
ssh $MASTERNODE 'for p in $(jps | grep ResourceManager | tr -s " " | cut -d " " -f 1);
        do echo $p; kill -9 $p; done' >& /dev/null

if [[ $MR_JOBHISTORY_SERVER == "true" ]]
then
	m_echo "Finishing JobHistoryServer:" $MASTERNODE
	ssh $MASTERNODE 'for p in $(jps | grep JobHistoryServer | tr -s " " | cut -d " " -f 1);
        	do echo $p; kill -9 $p; done' >& /dev/null
fi

sleep 1
