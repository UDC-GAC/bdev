#!/bin/sh

for SLAVE in $MASTERNODE $SLAVENODES
do
	echo "Stopping turbostat daemon in ${SLAVE}" >> ${BDW_LOG_DIR}/turbostat_log 2>&1
	ssh $SLAVE "source ${BDW_LOG_DIR}/config.sh; \
	${PYTHON3_BIN} ${BDWATCHDOG_DAEMONS_DIR}/turbostat.py stop" >> ${BDW_LOG_DIR}/turbostat_log 2>&1
done
