#!/bin/bash

if [[ $# -lt 1 ]]; then
       echo "$0 hostfile"
       exit 1
fi

INPUT_FILE="$1"
CURRENT_NODE="${HOSTNAME%%.*}"

while read -r NODE_NAME _; do
	NODE="${NODE_NAME%%.*}"
	
        if [[ "$NODE" == "localhost" ]]; then
        	echo "localhost"
        	break
        fi
        
	if [[ "$NODE" == "$CURRENT_NODE" ]]; then
		echo "$NODE_NAME"
		break
        fi
done < "$INPUT_FILE"

