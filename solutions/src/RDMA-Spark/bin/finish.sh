#!/bin/sh

SCRIPT=$SPARK_HOME/sbin/stop-all.sh

if [ -f "$SCRIPT" ]; then
	bash $SCRIPT
fi

bash $CLEAN_DAEMONS_SCRIPT

$COMMON_SRC_DIR/bin/spark-config.sh
