#!/bin/bash

mkdir -p "${BDW_LOG_DIR}/java_mappings"

if [[ ! -f "${BDW_LOG_DIR}/config.sh" ]]; then
    bash "${BDWATCHDOG_HOME}/gen-config.sh" > "${BDW_LOG_DIR}/config.sh"
fi

# Start turbostat daemon across all nodes in parallel
parallel_ssh ". '${BDW_LOG_DIR}/config.sh'; bash '${BDWATCHDOG_HOME}/turbostat-config.sh'; '${PYTHON_BIN}' '${BDWATCHDOG_DAEMONS_DIR}/turbostat.py' start" "${BDW_LOG_DIR}/turbostat_log"
