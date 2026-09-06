#!/bin/bash

generate_framework_config \
  "$HADOOP_CONF_DIR_SRC" \
  "$HADOOP_TEMPLATE_DIR" \
  "$HADOOP_CONF_DIR" \
  "$HADOOP_LOG_DIR" \
  "$MASTERFILE" \
  "$WORKERSFILE"
