#!/bin/bash

DOOL_PID=$(ps -elf | grep ${PYTHON_BIN} | grep ${DOOL_COMMAND_NAME} | grep -v "ssh" | grep -v "export" | awk '{print $4}')

if [[ -n "$DOOL_PID" ]]; then
	echo "$HOSTNAME: cleaning up ${DOOL_COMMAND_NAME} with PID $DOOL_PID"
	kill -9 $DOOL_PID
fi
