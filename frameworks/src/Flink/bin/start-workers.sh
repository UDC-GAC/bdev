#!/bin/bash
set -eo pipefail

if [[ -z "${FLINK_HOME:-}" || -z "${FLINK_CONF_DIR:-}" ]]; then
    echo "ERROR: FLINK_HOME and FLINK_CONF_DIR must be set" >&2
    exit 1
fi

WORKERSFILE="${FLINK_CONF_DIR}/workers"
if [[ ! -f "$WORKERSFILE" ]]; then
    echo "ERROR: Workers file not found in ${WORKERSFILE}" >&2
    exit 1
fi

FLINK_SSH_OPTS="${FLINK_SSH_OPTS:--o StrictHostKeyChecking=no}"
echo "Starting Flink TaskManagers..."

while IFS= read -r host || [[ -n "$host" ]]; do
    # Skip comments and empty lines
    [[ "$host" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${host// }" ]] && continue

    $SSH_CMD -n $FLINK_SSH_OPTS "$host" \
        "export FLINK_CONF_DIR=\"$FLINK_CONF_DIR\"; \
         export FLINK_LOG_DIR=\"${FLINK_LOG_DIR:-}\"; \
         export FLINK_PID_DIR=\"${FLINK_PID_DIR:-}\"; \
         export FLINK_LIB_DIR=\"${FLINK_PID_DIR:-}\"; \
         export HADOOP_CLASSPATH=\"${HADOOP_CLASSPATH:-}\"; \
         export HADOOP_CONF_DIR=\"${HADOOP_CONF_DIR:-}\"; \
         \"${FLINK_HOME}/bin/taskmanager.sh\" start" 2>&1 | sed "s/^/$host: /" &
done < "$WORKERSFILE"

wait
echo "All Flink TaskManagers started"
