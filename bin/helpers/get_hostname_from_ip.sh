#!/bin/bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
       echo "usage: $0 <hostfile> <ip> [loopback]" >&2
       exit 1
fi

INPUT_FILE="$1"
IP="$2"
LOOPBACK_IP="${3:-127.0.0.1}"

if [[ ! -r "$INPUT_FILE" ]]; then
    echo "Hostfile not found or not readable: $INPUT_FILE" >&2
    exit 1
fi

if [[ "$LOOPBACK_IP" == "$IP" ]]; then
    echo "localhost"
    exit 0
fi

while read -r NODE_NAME NODE_IP _ || [[ -n "$NODE_NAME" ]]; do
       [[ -z "$NODE_NAME" || "$NODE_NAME" =~ ^# ]] && continue
       [[ -z "$NODE_IP" ]] && continue
       
       if [[ "$NODE_IP" == "$IP" ]]; then
              echo "$NODE_NAME"
              exit 0
       fi
done < "$INPUT_FILE"

echo "IP address '$IP' not found in $INPUT_FILE" >&2
exit 1
