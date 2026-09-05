#!/bin/bash
set -eo pipefail

if [[ -z "${SPARK_HOME:-}" ]]; then
    echo "ERROR: SPARK_HOME is not set." >&2
    exit 1
fi

if [[ -z "${SPARK_CONF_DIR:-}" ]]; then
    echo "ERROR: SPARK_CONF_DIR must be exported before launching workers." >&2
    exit 1
fi

# Load local configuration to resolve master port and host
. "${SPARK_HOME}/sbin/spark-config.sh"
. "${SPARK_HOME}/bin/load-spark-env.sh"

SPARK_MASTER_PORT="${SPARK_MASTER_PORT:-7077}"
SPARK_MASTER_HOST="${$MASTERNODE:-$(hostname -f)}"
MASTER_URL="spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT}"

WORKERS_FILE="${SPARK_CONF_DIR}/workers"
if [[ ! -f "$WORKERS_FILE" ]]; then
    echo "ERROR: Workers file not found in ${WORKERS_FILE}" >&2
    exit 1
fi

SPARK_SSH_OPTS="${SPARK_SSH_OPTS:--o StrictHostKeyChecking=no}"

while IFS= read -r host || [[ -n "$host" ]]; do
    # Skip comments and empty lines
    [[ "$host" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${host// }" ]] && continue
    
    echo "Starting Spark worker on ${host}..."
    $SSH_CMD -n $SPARK_SSH_OPTS "$host" \
        "export SPARK_CONF_DIR=\"$SPARK_CONF_DIR\"; \
         export SPARK_LOG_DIR=\"${SPARK_LOG_DIR:-}\"; \
         export SPARK_PID_DIR=\"${SPARK_PID_DIR:-}\"; \
         \"${SPARK_HOME}/sbin/start-worker.sh\" \"$MASTER_URL\"" 2>&1 | sed "s/^/$host: /" &
done < "$WORKERS_FILE"

wait
echo "All Spark workers started"
