#!/bin/bash

# Avoid cleanup if framework does not exist
SCRIPT_MASTER="$FLINK_HOME/bin/jobmanager.sh"

if [[ -f "$SCRIPT_MASTER" ]]; then
	bash "$SCRIPT_MASTER" stop
	bash "$SOLUTION_DIR/bin/stop-workers.sh"
fi

"$COMMON_SRC_DIR/bin/stop_hdfs.sh"
bash "$CLEANUP_PROCESS_SCRIPT"
