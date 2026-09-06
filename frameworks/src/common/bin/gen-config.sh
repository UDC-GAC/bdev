#!/bin/bash

. "$BDEV_BIN_DIR/gen-config.sh"

generate_framework_config \
  "$HADOOP_CONF_DIR_SRC" \
  "$HADOOP_TEMPLATE_DIR" \
  "$HADOOP_CONF_DIR" \
  "$HADOOP_LOG_DIR" \
  "$HADOOP_WORKERSFILE"
