#!/bin/bash

bash $CLEANUP_YARN_SCRIPT
$COMMON_HADOOP_DIR/bin/stop_hdfs.sh
$COMMON_HADOOP_DIR/bin/stop_yarn.sh
bash $CLEANUP_PROCESS_SCRIPT
cleanup_report "$FRAMEWORK_REPORT_DIR"
