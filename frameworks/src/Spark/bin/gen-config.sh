#!/bin/bash

. "$BDEV_BIN_DIR/gen-config.sh"

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
