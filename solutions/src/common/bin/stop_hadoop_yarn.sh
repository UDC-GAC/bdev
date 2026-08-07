#!/bin/sh

export FORCE_DELETE_HDFS=false
bash $YARN_KILLALL_SCRIPT
$COMMON_SRC_DIR/bin/finish_hdfs.sh
$COMMON_SRC_DIR/bin/finish_yarn.sh
bash $CLEAN_DAEMONS_SCRIPT
bash $CLEAN_DATA_SCRIPT
