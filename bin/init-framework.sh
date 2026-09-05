#!/bin/bash

if [[ -z "$MASTERNODE" ]]; then
	m_exit "Master node is null. Revise network settings"
fi

if [[ -z "$WORKERNODES" ]]; then
	m_exit "Worker nodes are null. Revise network settings"
fi

#Generate configuration
m_echo "Generating configuration: $SOL_TEMPLATE_DIR"
. $GEN_CONFIG_SCRIPT

