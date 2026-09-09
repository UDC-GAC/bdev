#!/bin/bash

if [[ ! -d "${BDW_LOG_DIR}" ]]; then
	mkdir -p ${BDW_LOG_DIR}
	mkdir -p ${BDW_LOG_DIR}/java_mappings

	if [[ ! -f "${BDW_LOG_DIR}/config.sh" ]]; then
		bash ${BDWATCHDOG_HOME}/gen-config.sh > ${BDW_LOG_DIR}/config.sh
	fi
fi

# Deduplicate nodes in case the master is also a worker
UNIQUE_NODES=$(printf '%s\n' $MASTERNODE $WORKERNODES | sort -u)

for NODE in $UNIQUE_NODES; do
	echo "Starting nethogs daemon in ${NODE}" >> ${BDW_LOG_DIR}/nethogs_log 2>&1
	$SSH_CMD $NODE ". ${BDW_LOG_DIR}/config.sh; \
		${BDWATCHDOG_HOME}/nethogs-config.sh; \
		${PYTHON_BIN} ${BDWATCHDOG_DAEMONS_DIR}/nethogs.py start" >> ${BDW_LOG_DIR}/nethogs_log 2>&1
done
