#!/bin/sh

$SPARK_HOME/sbin/stop-all.sh

bash $CLEAN_DAEMONS_SCRIPT

# Get rid of jar files in user logs
eval $SPARK_BENCH_JAR_DELETE
