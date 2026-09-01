#!/bin/bash

echo "stop" | $FLINK_HOME/bin/yarn-session.sh -id $YARN_APP_ID

$COMMON_SRC_DIR/bin/stop_hadoop_yarn.sh
