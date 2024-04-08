#!/bin/sh

m_echo "Finishing"

export FORCE_DELETE_HDFS=$DELETE_HDFS

if [[ $NUM_CLUSTERS -gt 1 ]]; then
	export FORCE_DELETE_HDFS=true
fi

. $CLEAN_DATA_SCRIPT
