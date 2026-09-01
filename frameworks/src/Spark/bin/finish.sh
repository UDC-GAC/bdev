#!/bin/bash

# Avoid cleanup if solution does not exist
SCRIPT=$SPARK_HOME/sbin/stop-all.sh

if [ -f "$SCRIPT" ]; then
	bash $SCRIPT
fi

$COMMON_SRC_DIR/bin/finish_hdfs.sh
bash $CLEAN_DAEMONS_SCRIPT

# Get rid of jar files in user logs
eval $SPARK_BENCH_JAR_DELETE
