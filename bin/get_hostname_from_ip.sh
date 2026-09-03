#!/bin/bash

if [[ $# -lt 2 ]]; then
       echo "$0 hostfile IP [loopback]"
       exit 1
fi

INPUT_FILE="$1"
IP="$2"
LOOPBACK_IP="${3:-127.0.0.1}"

if [[ "$LOOPBACK_IP" == "$IP" ]]; then
    echo "localhost"
else
    while read -r NODE_NAME NODE_IP; do
        if [[ "$NODE_IP" == "$IP" ]]; then
            echo "$NODE_NAME"
            break
        fi
    done < "$INPUT_FILE"
fi
