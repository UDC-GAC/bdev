#!/bin/bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
       echo "Usage: $0 <hostfile> [target_node] [loopback_ip]" >&2
       exit 1
fi

INPUT_FILE="$1"
TARGET_NODE=""
LOOPBACK_IP="127.0.0.1"

if [[ $# -ge 2 ]]; then
    if [[ "$2" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # If the 2nd argument is an IP address, it is [loopback_ip]
        LOOPBACK_IP="$2"
    else
        # Target hostname
        TARGET_NODE="$2"
        LOOPBACK_IP="${3:-127.0.0.1}"
    fi
fi

if [[ ! -r "$INPUT_FILE" ]]; then
    echo "Hostfile not found or not readable: $INPUT_FILE" >&2
	exit 1
fi

if [[ -z "$TARGET_NODE" ]]; then
    TARGET_NODE=$(hostname -s 2>/dev/null || hostname)
fi

TARGET_NODE="${TARGET_NODE%%.*}"

while read -r NODE_NAME NODE_IP _ || [[ -n "$NODE_NAME" ]]; do
	[[ -z "$NODE_NAME" || "$NODE_NAME" =~ ^# ]] && continue
	[[ -z "$NODE_IP" ]] && continue
	
	NODE="${NODE_NAME%%.*}"

	if [[ "$NODE" == "localhost" ]]; then
		echo "$LOOPBACK_IP"
		exit 0
	fi

	if [[ "$NODE" == "$TARGET_NODE" ]]; then
		echo "$NODE_IP"
		exit 0
	fi
done < "$INPUT_FILE"

echo "Node '$TARGET_NODE' not found in $INPUT_FILE" >&2
exit 1
