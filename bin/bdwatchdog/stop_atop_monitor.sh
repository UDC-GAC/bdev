#!/bin/sh

for SLAVE in $MASTERNODE $SLAVENODES
do
	echo "Stopping atop daemon in ${SLAVE}" >> ${BDW_LOG_DIR}/atop_log 2>&1
	ssh $SLAVE "source ${BDW_LOG_DIR}/config.sh; \
	${PYTHON3_BIN} ${BDWATCHDOG_DAEMONS_DIR}/atop.py stop" >> ${BDW_LOG_DIR}/atop_log 2>&1
done
