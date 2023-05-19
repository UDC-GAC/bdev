#!/bin/sh

mkdir -p $RAPLLOGDIR

OLD_PWD=$PWD

cd $RAPL_HOME/rapl_plot

make >> ${RAPLLOGDIR}/log 2>&1

cd $OLD_PWD

export NODE_NUMBER=0
for SLAVE in $MASTERNODE $SLAVENODES
do
	RAPLNODEDIR=${RAPLLOGDIR}/node-${NODE_NUMBER}
	RAPLTMPDIR=${TMP_DIR}/rapl/node-${NODE_NUMBER}
	mkdir -p ${RAPLNODEDIR}
	echo "Starting RAPL monitor in ${SLAVE}, storing data on ${RAPLNODEDIR}" >> ${RAPLLOGDIR}/log 2>&1
	nohup $SSH_CMD $SLAVE "export RAPLLOGFILE=${RAPLNODEDIR}/rapl; \
		export RAPLTMPDIR=${RAPLTMPDIR}; \
		export RAPL_HOME=${RAPL_HOME}; \
		export RAPL_SECONDS_INTERVAL=${RAPL_SECONDS_INTERVAL}; \
		bash $RAPL_HOME/rapl_monitor.sh" > ${RAPLNODEDIR}/rapl.out 2>&1 &
	
	export NODE_NUMBER=$(( $NODE_NUMBER + 1 ))
done


