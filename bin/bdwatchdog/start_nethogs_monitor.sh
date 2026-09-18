#!/bin/bash

mkdir -p "${BDW_LOG_DIR}/java_mappings"

if [[ ! -f "${BDW_LOG_DIR}/config.sh" ]]; then
    bash "${BDWATCHDOG_HOME}/gen-config.sh" > "${BDW_LOG_DIR}/config.sh"
fi

parallel_ssh ". '${BDW_LOG_DIR}/config.sh'; . '${BDWATCHDOG_HOME}/nethogs-config.sh'; '${PYTHON_BIN}' '${BDWATCHDOG_DAEMONS_DIR}/nethogs.py' start" "${BDW_LOG_DIR}/nethogs_log" "Starting nethogs monitor"
