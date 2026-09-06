#!/bin/bash

if [[ -z "$MASTERNODE" ]]; then
	m_exit "Master node is null. Revise network settings"
fi

if [[ -z "$WORKERNODES" ]]; then
	m_exit "Worker nodes are null. Revise network settings"
fi

#Generate configuration
. "$GEN_CONFIG_SCRIPT"

m_echo "Master: $MASTERNODE"
m_echo "Workers:"
while read -r NODE; do
    m_echo $'\t'"$NODE"
done < "$WORKERSFILE"
