#!/bin/sh

export NODE_NUMBER=1
for SLAVE in $SLAVES
do
	echo "Creating ilo_monitor to ${SLAVE}, storing data on ${POWERLOGDIR}/node-${NODE_NUMBER}.pow" \
		>> ${POWERLOGDIR}/log 2>&1
	bash $ILO_HOME/ilo_monitor.sh $SLAVE > ${POWERLOGDIR}/node-${NODE_NUMBER}.pow &
	
	export NODE_NUMBER=$(( $NODE_NUMBER + 1 ))
done

export NODE_NUMBER=0
echo "Creating ilo_monitor to ${MASTERNODE}, storing data on ${POWERLOGDIR}/node-${NODE_NUMBER}.pow" \
	>> ${POWERLOGDIR}/log 2>&1
bash $ILO_HOME/ilo_monitor.sh $MASTERNODE > ${POWERLOGDIR}/node-${NODE_NUMBER}.pow

