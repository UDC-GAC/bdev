#!/bin/bash

bash $CLEANUP_YARN_SCRIPT
$COMMON_SRC_DIR/bin/stop_hdfs.sh
$COMMON_SRC_DIR/bin/stop_yarn.sh
bash $CLEANUP_PROCESS_SCRIPT
