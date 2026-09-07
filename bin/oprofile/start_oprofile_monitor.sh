#!/bin/bash


mkdir -p $OPROFILELOGDIR

export NODE_NUMBER=0
for NODE in $MASTERNODE $WORKERNODES
do
	OPROFILENODEDIR=${OPROFILELOGDIR}/node-${NODE_NUMBER}
	mkdir -p ${OPROFILENODEDIR}
	echo "Starting oprofile monitor in ${NODE}, storing data on ${OPROFILENODEDIR}" >> ${OPROFILELOGDIR}/log 2>&1
	nohup $SSH_CMD $NODE "export OPROFILELOGFILE=${OPROFILENODEDIR}/oprofile; \
		export OPROFILE_BIN=${OPROFILE_BIN}; \
		export OPROFILE_EVENTS=${OPROFILE_EVENTS}; \
		bash $OPROFILE_HOME/oprofile_monitor.sh" > ${OPROFILENODEDIR}/oprofile.out 2>&1 &
	
	export NODE_NUMBER=$(( $NODE_NUMBER + 1 ))
done


