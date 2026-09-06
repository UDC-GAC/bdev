#!/bin/bash

. "$GEN_CONFIG_SCRIPT"

# Spark
generate_framework_config \
    "$SPARK_CONF_DIR_SRC" \
    "$SPARK_TEMPLATE_DIR" \
    "$SPARK_CONF_DIR" \
    "$SPARK_LOG_DIR" \
    "$MASTERFILE" \
    "$WORKERSFILE"

# Hadoop
. "$COMMON_SRC_DIR/bin/gen-config.sh"
