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
	echo "Starting atop daemon in ${SLAVE}" >> ${BDW_LOG_DIR}/atop_log 2>&1
	$SSH_CMD $SLAVE "source ${BDW_LOG_DIR}/config.sh; \
	${PYTHON3_BIN} ${BDWATCHDOG_DAEMONS_DIR}/atop.py start" >> ${BDW_LOG_DIR}/atop_log 2>&1
done
