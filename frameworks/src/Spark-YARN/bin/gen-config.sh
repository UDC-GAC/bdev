#!/bin/bash

# Spark
generate_framework_config \
    "$SOLUTION_CONF_DIR_SRC" \
    "$SOLUTION_TEMPLATE_DIR" \
    "$SOLUTION_CONF_DIR" \
    "$SOLUTION_LOG_DIR" \
    "$MASTERFILE" \
    "$WORKERSFILE"

# Hadoop
"$COMMON_SRC_DIR/bin/gen-config.sh"
