#!/bin/sh

# Avoid cleanup if solution does not exist
SCRIPT=$SPARK_HOME/sbin/stop-all.sh

if [ -f "$SCRIPT" ]; then
	bash $SCRIPT
fi

bash $CLEAN_DAEMONS_SCRIPT
