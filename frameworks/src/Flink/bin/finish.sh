#!/bin/bash

# Avoid cleanup if solution does not exist
SCRIPT=$FLINK_HOME/bin/stop-cluster.sh

if [ -f "$SCRIPT" ]; then
	bash $SCRIPT
fi

$COMMON_SRC_DIR/bin/finish_hdfs.sh
bash $CLEANUP_PROCESS_SCRIPT
