#!/bin/sh

if [ ! -d "${BDW_LOG_DIR}" ]; then
	mkdir -p ${BDW_LOG_DIR}
	mkdir -p ${BDW_LOG_DIR}/java_mappings

	if [ ! -f "${BDW_LOG_DIR}/config.sh" ]; then
		bash ${BDWATCHDOG_HOME}/gen-config.sh > ${BDW_LOG_DIR}/config.sh
	fi
fi

for SLAVE in $MASTERNODE $SLAVENODES
do
	echo "Starting turbostat daemon in ${SLAVE}" >> ${BDW_LOG_DIR}/turbostat_log 2>&1
	ssh $SLAVE "source ${BDW_LOG_DIR}/config.sh; \
	${BDWATCHDOG_HOME}/turbostat-config.sh; \
        ${PYTHON3_BIN} ${BDWATCHDOG_DAEMONS_DIR}/turbostat.py start" >> ${BDW_LOG_DIR}/turbostat_log 2>&1
done
