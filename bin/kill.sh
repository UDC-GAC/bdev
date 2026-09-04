#!/bin/bash

if [[ $# -ne 2 ]]; then
       echo "$0 JPS_CMD JAVA_APP"
       exit 1
fi

DAEMON_PIDS=$("$1" | awk -v process="$2" '$2 ~ process {print $1}')

if [[ -n "$DAEMON_PIDS" ]]; then
	kill -9 $DAEMON_PIDS 2>/dev/null
fi
