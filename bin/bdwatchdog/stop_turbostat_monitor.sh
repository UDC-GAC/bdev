#!/bin/bash

# Deduplicate nodes in case the master is also a worker
UNIQUE_NODES=$(printf '%s\n' $MASTERNODE $WORKERNODES | sort -u)

for NODE in $UNIQUE_NODES; do
	echo "Stopping turbostat daemon in ${NODE}" >> ${BDW_LOG_DIR}/turbostat_log 2>&1
	$SSH_CMD $NODE ". ${BDW_LOG_DIR}/config.sh; \
		${PYTHON_BIN} ${BDWATCHDOG_DAEMONS_DIR}/turbostat.py stop" >> ${BDW_LOG_DIR}/turbostat_log 2>&1
done
