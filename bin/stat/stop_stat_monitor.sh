#!/bin/sh

for SLAVE in $MASTERNODE $SLAVENODES
do
	echo "Stopping dool monitor in ${SLAVE}" >> ${STATLOGDIR}/log 2>&1
	$SSH_CMD $SLAVE "export DOOL_COMMAND_NAME=${DOOL_COMMAND_NAME};export PYTHON3_BIN=${PYTHON3_BIN};\
		${STAT_HOME}/kill_stat_monitor.sh" >> ${STATLOGDIR}/log 2>&1
done
