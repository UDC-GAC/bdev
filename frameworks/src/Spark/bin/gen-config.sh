#!/bin/bash

. "$GEN_CONFIG_SCRIPT"

generate_framework_config \
    "$SPARK_CONF_DIR_SRC" \
    "$SPARK_TEMPLATE_DIR" \
    "$SPARK_CONF_DIR" \
    "$SPARK_LOG_DIR" \
    "$MASTERFILE" \
    "$WORKERSFILE"

if [[ "${STORAGE_BACKEND,,}" == "hdfs" ]]; then
  generate_framework_config \
    "$HADOOP_CONF_DIR_SRC" \
    "$HADOOP_TEMPLATE_DIR" \
    "$HADOOP_CONF_DIR" \
    "$HADOOP_LOG_DIR" \
    "$MASTERFILE" \
    "$WORKERSFILE"
fi
