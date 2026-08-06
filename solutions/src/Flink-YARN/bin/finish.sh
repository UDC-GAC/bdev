#!/bin/sh

echo "stop" | $FLINK_HOME/bin/yarn-session.sh -id $YARN_APP_ID

bash $YARN_KILLALL_SCRIPT
${COMMON_SRC_DIR}/bin/finish_yarn.sh
${COMMON_SRC_DIR}/bin/finish_hdfs.sh
bash $CLEAN_DAEMONS_SCRIPT
