#!/bin/sh

$SPARK_HOME/sbin/stop-all.sh

bash $CLEAN_DAEMONS_SCRIPT

$COMMON_SRC_DIR/bin/spark-config.sh
