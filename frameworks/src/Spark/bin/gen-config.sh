#!/bin/bash

# Spark
generate_framework_config \
    "$FRAMEWORK_CONF_DIR_SRC" \
    "$FRAMEWORK_TEMPLATE_DIR" \
    "$FRAMEWORK_CONF_DIR" \
    "$FRAMEWORK_LOG_DIR" \
    "$FRAMEWORK_LIB_DIR" \
    "$MASTERFILE" \
    "$WORKERSFILE"

# Hadoop
if [[ "${RESOURCE_MANAGER:-standalone}" == "yarn" || "${STORAGE_BACKEND,,}" == "hdfs" ]]; then
    . "$COMMON_HADOOP_DIR/bin/gen-config.sh"
fi
