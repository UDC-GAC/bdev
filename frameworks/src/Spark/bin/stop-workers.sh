#!/bin/bash
set -eo pipefail

if [[ -z "${SPARK_HOME:-}" || -z "${SPARK_CONF_DIR:-}" ]]; then
    echo "ERROR: SPARK_HOME and SPARK_CONF_DIR must be set" >&2
    exit 1
fi

WORKERS_FILE="${SPARK_CONF_DIR}/workers"
if [[ ! -f "$WORKERSFILE" ]]; then
    echo "ERROR: Workers file not found in ${WORKERSFILE}" >&2
    exit 1
fi

SPARK_SSH_OPTS="${SPARK_SSH_OPTS:--o StrictHostKeyChecking=no}"
echo "Stopping Spark workers..."

while IFS= read -r host || [[ -n "$host" ]]; do
    # Skip comments and empty lines
    [[ "$host" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${host// }" ]] && continue

    $SSH_CMD -n $SPARK_SSH_OPTS "$host" \
        "export SPARK_CONF_DIR=\"$SPARK_CONF_DIR\"; \
         \"${SPARK_HOME}/sbin/stop-worker.sh\"" 2>&1 | sed "s/^/$host: /" &
done < "$WORKERS_FILE"

wait
echo "All Spark workers stopped"
