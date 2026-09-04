#!/bin/bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
       echo "Usage: $0 <hostfile>" >&2
       exit 1
fi

INPUT_FILE="$1"

if [[ ! -r "$INPUT_FILE" ]]; then
    echo "Hostfile not found or not readable: $INPUT_FILE" >&2
	exit 1
fi

CURRENT_NODE=$(hostname -s 2>/dev/null || hostname)
CURRENT_NODE="${CURRENT_NODE%%.*}"

while read -r NODE_NAME _ || [[ -n "$NODE_NAME" ]]; do
	[[ -z "$NODE_NAME" || "$NODE_NAME" =~ ^# ]] && continue
	
	NODE="${NODE_NAME%%.*}"
	
	if [[ "$NODE" == "localhost" ]]; then
		echo "localhost"
		exit 0
	fi
        
	if [[ "$NODE" == "$CURRENT_NODE" ]]; then
		echo "$NODE_NAME"
		exit 0
	fi
done < "$INPUT_FILE"

echo "Node '$CURRENT_NODE' not found in $INPUT_FILE" >&2
exit 1
