#!/bin/bash

mkdir -p $OPROFILELOGDIR
NODE_NUMBER=0

# Deduplicate nodes in case the master is also a worker
UNIQUE_NODES=$(printf '%s\n' $MASTERNODE $WORKERNODES | sort -u)

for NODE in $UNIQUE_NODES; do
	OPROFILENODEDIR=${OPROFILELOGDIR}/node-${NODE_NUMBER}
	mkdir -p ${OPROFILENODEDIR}
	echo "Starting oprofile monitor in ${NODE}, storing data on ${OPROFILENODEDIR}" >> ${OPROFILELOGDIR}/log 2>&1
	nohup $SSH_CMD $NODE "export OPROFILELOGFILE=${OPROFILENODEDIR}/oprofile; \
		export OPROFILE_BIN=${OPROFILE_BIN}; \
		export OPROFILE_EVENTS=${OPROFILE_EVENTS}; \
		bash $OPROFILE_HOME/oprofile_monitor.sh" > ${OPROFILENODEDIR}/oprofile.out 2>&1 &
	
	NODE_NUMBER=$(( $NODE_NUMBER + 1 ))
done


