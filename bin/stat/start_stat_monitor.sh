#!/bin/bash

mkdir -p $STATLOGDIR
NODE_NUMBER=0

# Deduplicate nodes in case the master is also a worker
UNIQUE_NODES=$(printf '%s\n' $MASTERNODE $WORKERNODES | sort -u)

for NODE in $UNIQUE_NODES; do
	STATNODEDIR=${STATLOGDIR}/node-${NODE_NUMBER}
	STATLOGFILE=${STATNODEDIR}/stat.csv
	mkdir -p ${STATNODEDIR}
	echo "Starting dool monitor in ${NODE}, storing data on ${STATNODEDIR}" >> ${STATLOGDIR}/log 2>&1
	nohup $SSH_CMD $NODE "${PYTHON_BIN} ${DOOL_COMMAND} ${DOOL_OPTIONS} --output ${STATLOGFILE} ${STAT_SECONDS_INTERVAL}" > ${STATNODEDIR}/stat.out 2>&1 &
	NODE_NUMBER=$(( $NODE_NUMBER + 1 ))
done
