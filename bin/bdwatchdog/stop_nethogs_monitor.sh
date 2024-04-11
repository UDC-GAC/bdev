#!/bin/sh

for SLAVE in $MASTERNODE $SLAVENODES
do
	echo "Stopping nethogs daemon in ${SLAVE}" >> ${BDW_LOG_DIR}/nethogs_log 2>&1
	$SSH_CMD $SLAVE "source ${BDW_LOG_DIR}/config.sh; \
	${PYTHON3_BIN} ${BDWATCHDOG_DAEMONS_DIR}/nethogs.py stop" >> ${BDW_LOG_DIR}/nethogs_log 2>&1
done
