#!/bin/sh

SCRIPT=$FLINK_HOME/bin/stop-cluster.sh

if [ -f "$SCRIPT" ]; then
	bash $SCRIPT
fi

bash $CLEAN_DAEMONS_SCRIPT
