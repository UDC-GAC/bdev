#!/bin/bash

for NODE in $MASTERNODE $SLAVENODES
do
	echo "Stopping atop daemon in ${NODE}" >> ${BDW_LOG_DIR}/atop_log 2>&1
	$SSH_CMD $NODE ". ${BDW_LOG_DIR}/config.sh; \
		${PYTHON_BIN} ${BDWATCHDOG_DAEMONS_DIR}/atop.py stop" >> ${BDW_LOG_DIR}/atop_log 2>&1
done
