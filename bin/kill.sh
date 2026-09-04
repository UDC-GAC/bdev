#!/bin/bash

if [[ $# -ne 2 ]]; then
       echo "$0 JPS_CMD JAVA_APP"
       exit 1
fi

DAEMON_PIDS=$($1 | grep -E "$2" | cut -f 1 -d " ")

if [[ -n "$DAEMON_PIDS" ]]; then
	kill -9 $DAEMON_PIDS 2>/dev/null
fi
