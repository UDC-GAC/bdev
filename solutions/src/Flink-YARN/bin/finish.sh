#!/bin/sh

echo "stop" | $FLINK_HOME/bin/yarn-session.sh -id $YARN_APP_ID

bash $YARN_KILLALL_SCRIPT
bash $CLEAN_DAEMONS_SCRIPT
