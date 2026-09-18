#!/bin/bash

parallel_ssh "pkill -u '$USER' -9 -f '(^|.*/)python.*${DOOL_COMMAND_NAME}' 2>/dev/null || true" "${STATLOGDIR}/log" "Stopping dool monitor"
