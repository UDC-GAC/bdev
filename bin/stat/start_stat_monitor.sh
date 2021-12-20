#!/bin/sh

mkdir -p $STATLOGDIR

export NODE_NUMBER=0

for SLAVE in $MASTERNODE $SLAVENODES
do
	STATNODEDIR=${STATLOGDIR}/node-${NODE_NUMBER}
	STATLOGFILE=${STATNODEDIR}/stat.csv
	mkdir -p ${STATNODEDIR}
	echo "Starting dstat/dool monitor in ${SLAVE}, storing data on ${STATNODEDIR}" >> ${STATLOGDIR}/log 2>&1
	nohup ssh $SLAVE "${PYTHON3_BIN} ${DOOL_COMMAND} ${DOOL_OPTIONS} --output ${STATLOGFILE} ${STAT_SECONDS_INTERVAL}" > ${STATNODEDIR}/stat.out 2>&1 &
	export NODE_NUMBER=$(( $NODE_NUMBER + 1 ))
done
