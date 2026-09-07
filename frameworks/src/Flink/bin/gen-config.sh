#!/bin/bash

if [[ "${RESOURCE_MANAGER:-standalone}" == "standalone" ]]; then
	if [[ "$FLINK_TASKMANAGERS_PER_NODE" -gt 1 ]]; then
		awk -v n="$FLINK_TASKMANAGERS_PER_NODE" '{ for (i = 0; i < n; i++) print }' "$WORKERSFILE" > "${WORKERSFILE}.tmp"
		mv "${WORKERSFILE}.tmp" "$WORKERSFILE"
	fi
fi

# Flink
generate_framework_config \
    "$SOLUTION_CONF_DIR_SRC" \
    "$SOLUTION_TEMPLATE_DIR" \
    "$SOLUTION_CONF_DIR" \
    "$SOLUTION_LOG_DIR" \
    "$MASTERFILE" \
    "$WORKERSFILE"

# Hadoop
if [[ "${RESOURCE_MANAGER:-standalone}" == "yarn" || "${STORAGE_BACKEND,,}" == "hdfs" ]]; then
	. "$COMMON_SRC_DIR/bin/gen-config.sh"
fi
