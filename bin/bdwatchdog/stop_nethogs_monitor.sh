#!/bin/bash

for NODE in $MASTERNODE $WORKERNODES
do
	echo "Stopping nethogs daemon in ${NODE}" >> ${BDW_LOG_DIR}/nethogs_log 2>&1
	$SSH_CMD $NODE ". ${BDW_LOG_DIR}/config.sh; \
		${PYTHON_BIN} ${BDWATCHDOG_DAEMONS_DIR}/nethogs.py stop" >> ${BDW_LOG_DIR}/nethogs_log 2>&1
done
