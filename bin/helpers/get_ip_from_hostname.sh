#!/bin/bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
       echo "Usage: $0 <hostfile> [loopback_ip]" >&2
       exit 1
fi

INPUT_FILE="$1"
LOOPBACK_IP="${2:-127.0.0.1}"

if [[ ! -r "$INPUT_FILE" ]]; then
    echo "Hostfile not found or not readable: $INPUT_FILE" >&2
	exit 1
fi

CURRENT_NODE="${HOSTNAME:-$(hostname -s)}"
CURRENT_NODE="${CURRENT_NODE%%.*}"

while read -r NODE_NAME NODE_IP || [[ -n "$NODE_NAME" ]]; do
	[[ -z "$NODE_NAME" || "$NODE_NAME" =~ ^# ]] && continue
	[[ -z "$NODE_IP" ]] && continue
	
	NODE="${NODE_NAME%%.*}"

	if [[ "$NODE" == "localhost" ]]; then
		echo "$LOOPBACK_IP"
		exit 0
	fi

	if [[ "$NODE" == "$CURRENT_NODE" ]]; then
		echo "$NODE_IP"
		exit 0
	fi
done < "$INPUT_FILE"

echo "Node '$CURRENT_NODE' not found in $INPUT_FILE" >&2
exit 1
