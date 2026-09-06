#!/bin/bash

. "$BDEV_BIN_DIR/gen-config.sh"

export WORKERSFILE=$HADOOP_WORKERSFILE

generate_framework_config \
  "$HADOOP_CONF_DIR_SRC" \
  "$HADOOP_TEMPLATE_DIR" \
  "$HADOOP_CONF_DIR" \
  "$HADOOP_LOG_DIR" \
  "$WORKERSFILE"
