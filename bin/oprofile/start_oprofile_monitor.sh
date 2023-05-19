#!/bin/sh


mkdir -p $OPROFILELOGDIR

export NODE_NUMBER=0
for SLAVE in $MASTERNODE $SLAVENODES
do
	OPROFILENODEDIR=${OPROFILELOGDIR}/node-${NODE_NUMBER}
	mkdir -p ${OPROFILENODEDIR}
	echo "Starting oprofile monitor in ${SLAVE}, storing data on ${OPROFILENODEDIR}" >> ${OPROFILELOGDIR}/log 2>&1
	nohup $SSH_CMD $SLAVE "export OPROFILELOGFILE=${OPROFILENODEDIR}/oprofile; \
		export OPROFILE_BIN_DIR=${OPROFILE_BIN_DIR}; \
		export OPROFILE_EVENTS=${OPROFILE_EVENTS}; \
		bash $OPROFILE_HOME/oprofile_monitor.sh" > ${OPROFILENODEDIR}/oprofile.out 2>&1 &
	
	export NODE_NUMBER=$(( $NODE_NUMBER + 1 ))
done


