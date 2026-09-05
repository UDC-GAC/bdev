#!/bin/bash

# Avoid cleanup if framework does not exist
SCRIPT_MASTER="$SPARK_HOME/sbin/stop-master.sh"
SCRIPT_WORKERS="$SOLUTION_DIR/bin/stop-workers.sh"

if [ -f "$SCRIPT_MASTER" ]; then
	bash $SCRIPT_MASTER
fi

if [ -f "$SCRIPT_WORKERS" ]; then
	bash $SCRIPT_WORKERS
fi

$COMMON_SRC_DIR/bin/finish_hdfs.sh
bash $CLEANUP_PROCESS_SCRIPT

# Get rid of jar files in user logs
eval $SPARK_BENCH_JAR_DELETE
