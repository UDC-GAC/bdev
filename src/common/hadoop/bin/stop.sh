#!/bin/bash

cleanup_yarn "$YARN_EXECUTABLE"
$COMMON_HADOOP_DIR/bin/stop_hdfs.sh
$COMMON_HADOOP_DIR/bin/stop_yarn.sh
cleanup_process
cleanup_report "$FRAMEWORK_REPORT_DIR"
