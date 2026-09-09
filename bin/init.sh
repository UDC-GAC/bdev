#!/bin/bash

m_start_message

m_echo "Loading hostfile..."

# Load hostfile
load_hostfile

if [[ -z "$MASTERNODE" ]]; then
	m_exit "Master node is null. Revise network settings"
fi

if [[ -z "$WORKERNODES" ]]; then
	m_exit "Worker nodes are null. Revise network settings"
fi

. $CLEANUP_PROCESS_SCRIPT

begin_report
