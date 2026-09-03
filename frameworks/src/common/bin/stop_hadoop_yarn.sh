#!/bin/bash

bash $CLEANUP_YARN_SCRIPT
$COMMON_SRC_DIR/bin/finish_hdfs.sh
$COMMON_SRC_DIR/bin/finish_yarn.sh
bash $CLEANUP_PROCESS_SCRIPT
