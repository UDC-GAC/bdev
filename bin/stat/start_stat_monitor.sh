#!/bin/bash

mkdir -p $STATLOGDIR

export NODE_NUMBER=0

for NODE in $MASTERNODE $WORKERNODES
do
	STATNODEDIR=${STATLOGDIR}/node-${NODE_NUMBER}
	STATLOGFILE=${STATNODEDIR}/stat.csv
	mkdir -p ${STATNODEDIR}
	echo "Starting dool monitor in ${NODE}, storing data on ${STATNODEDIR}" >> ${STATLOGDIR}/log 2>&1
	nohup $SSH_CMD $NODE "${PYTHON_BIN} ${DOOL_COMMAND} ${DOOL_OPTIONS} --output ${STATLOGFILE} ${STAT_SECONDS_INTERVAL}" > ${STATNODEDIR}/stat.out 2>&1 &
	export NODE_NUMBER=$(( $NODE_NUMBER + 1 ))
done
