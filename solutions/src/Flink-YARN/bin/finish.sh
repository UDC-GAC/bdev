#!/bin/sh

$FLINK_HOME/bin/stop-cluster.sh

bash $CLEAN_DAEMONS_SCRIPT
