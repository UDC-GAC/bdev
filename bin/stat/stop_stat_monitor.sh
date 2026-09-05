#!/bin/bash

for NODE in $MASTERNODE $WORKERNODES
do
	echo "Stopping dool monitor in ${NODE}" >> ${STATLOGDIR}/log 2>&1
	$SSH_CMD $NODE "export DOOL_COMMAND_NAME=${DOOL_COMMAND_NAME};export PYTHON_BIN=${PYTHON_BIN};\
		${STAT_HOME}/kill_stat_monitor.sh" >> ${STATLOGDIR}/log 2>&1
done
