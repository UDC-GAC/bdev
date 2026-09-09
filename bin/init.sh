#!/bin/bash

m_start_message

# Load hostfile
load_hostfile
# Perform network discovery
network_discovery

if [[ -z "$MASTERNODE" ]]; then
	m_exit "Master node is null. Revise network settings"
fi

if [[ -z "$WORKERNODES" ]]; then
	m_exit "Worker nodes are null. Revise network settings"
fi

begin_report
