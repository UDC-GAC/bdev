#!/bin/sh

bash $CLEAN_DAEMONS_SCRIPT

$COMMON_SRC_DIR/bin/spark-config.sh

# Get rid of jar files in user logs
eval $SPARK_BENCH_JAR_DELETE
