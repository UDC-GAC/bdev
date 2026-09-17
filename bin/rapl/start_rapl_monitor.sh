#!/bin/bash

mkdir -p $RAPLLOGDIR
NODE_NUMBER=0

# Deduplicate nodes in case the master is also a worker
UNIQUE_NODES=$(printf '%s\n' $MASTERNODE $WORKERNODES | sort -u)

for NODE in $UNIQUE_NODES; do
	RAPLNODEDIR=${RAPLLOGDIR}/node-${NODE_NUMBER}
	RAPLTMPDIR=${TMP_DIR}/rapl/node-${NODE_NUMBER}
	mkdir -p ${RAPLNODEDIR}
	echo "Starting RAPL monitor in ${NODE}, storing data on ${RAPLNODEDIR}" >> ${RAPLLOGDIR}/log 2>&1
	nohup $SSH_CMD $NODE "export RAPLLOGFILE=${RAPLNODEDIR}/rapl; \
		export RAPLTMPDIR=${RAPLTMPDIR}; \
		export RAPL_HOME=${RAPL_HOME}; \
		export RAPL_COMMAND_NAME=${RAPL_COMMAND_NAME}; \
		export RAPL_SECONDS_INTERVAL=${RAPL_SECONDS_INTERVAL}; \
		bash ${RAPL_HOME}/rapl_monitor.sh" > ${RAPLNODEDIR}/rapl.out 2>&1 &
	
	NODE_NUMBER=$(( $NODE_NUMBER + 1 ))
done
