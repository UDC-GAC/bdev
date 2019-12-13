#!/bin/sh

mkdir -p $STATLOGDIR

export NODE_NUMBER=0
for SLAVE in $MASTERNODE $SLAVENODES
do
	STATNODEDIR=${STATLOGDIR}/node-${NODE_NUMBER}
	mkdir -p ${STATNODEDIR}
	echo "Starting dstat monitor in ${SLAVE}, storing data on ${STATNODEDIR}" >> ${STATLOGDIR}/log 2>&1
	nohup ssh $SLAVE "export STATLOGFILE=${STATNODEDIR}/stat.csv; \
		export DSTAT=${DSTAT}; \
		export STAT_SECONDS_INTERVAL=${STAT_SECONDS_INTERVAL}; \
		bash ${STAT_HOME}/stat_monitor.sh" > ${STATNODEDIR}/stat.out 2>&1 &
	
	export NODE_NUMBER=$(( $NODE_NUMBER + 1 ))
done
