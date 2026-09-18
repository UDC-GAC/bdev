#!/bin/bash

parallel_ssh ". '${BDW_LOG_DIR}/config.sh'; '${PYTHON_BIN}' '${BDWATCHDOG_DAEMONS_DIR}/atop.py' stop" "${BDW_LOG_DIR}/atop_log"
