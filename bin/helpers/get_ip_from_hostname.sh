#!/bin/bash

if [[ $# -lt 1 ]]; then
       echo "$0 hostfile [loopback]"
       exit 1
fi

INPUT_FILE="$1"
LOOPBACK_IP="${2:-127.0.0.1}"
CURRENT_NODE="${HOSTNAME%%.*}"

while read -r NODE_NAME NODE_IP; do
	NODE="${NODE_NAME%%.*}"

	if [[ "$NODE" == "localhost" ]]; then
		echo "$LOOPBACK_IP"
		break
	fi

	if [[ "$NODE" == "$CURRENT_NODE" ]]; then
		echo "$NODE_IP"
		break
	fi
done < "$INPUT_FILE"
