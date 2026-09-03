#!/bin/bash

m_echo "Finishing..."

export FORCE_DELETE_HDFS=$DELETE_HDFS

if [[ "$NUM_CLUSTERS" -gt 1 ]]; then
	export FORCE_DELETE_HDFS=true
fi

. $CLEANUP_DATA_SCRIPT

m_stop_message
