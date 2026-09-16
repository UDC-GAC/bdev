#!/bin/bash

m_echo "Finishing..."

export FORCE_WIPE_HDFS=$WIPE_HDFS_ON_EXIT

if [[ "$NUM_CLUSTERS" -gt 1 ]]; then
	export FORCE_WIPE_HDFS=true
fi

. $CLEANUP_DATA_SCRIPT

[[ -d "$REPORT_DIR" ]] && cleanup_report "$REPORT_DIR"

m_stop_message
