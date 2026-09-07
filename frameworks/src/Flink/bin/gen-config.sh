#!/bin/bash

if [[ "$FLINK_TASKMANAGERS_PER_NODE" -gt 1 ]]; then
	NODES=$(cat $WORKERSFILE)
	rm -f "$WORKERSFILE"
	for NODE in $NODES; do
		i=1
		while [[ "$i" -le "$FLINK_TASKMANAGERS_PER_NODE" ]]; do
			echo $NODE >> $WORKERSFILE
			i=$((i + 1))
		done
	done
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
if [[ "${STORAGE_BACKEND,,}" == "hdfs" ]]; then
	"$COMMON_SRC_DIR/bin/gen-config.sh"
fi
