#!/bin/bash

# Spark
generate_framework_config \
    "$SOLUTION_CONF_DIR_SRC" \
    "$SOLUTION_TEMPLATE_DIR" \
    "$SOLUTION_CONF_DIR" \
    "$SOLUTION_LOG_DIR" \
    "$SOLUTION_LIB_DIR" \
    "$MASTERFILE" \
    "$WORKERSFILE"

# Hadoop
if [[ "${RESOURCE_MANAGER:-standalone}" == "yarn" || "${STORAGE_BACKEND,,}" == "hdfs" ]]; then
    . "$COMMON_HADOOP_DIR/bin/gen-config.sh"
fi
