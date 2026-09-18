#!/bin/bash

#!/bin/bash

mkdir -p "$STATLOGDIR"
NODE_NUMBER=0

# Deduplicate nodes in case the master is also a worker
UNIQUE_NODES=$(printf '%s\n' $MASTERNODE $WORKERNODES | sort -u)

for NODE in $UNIQUE_NODES; do
    STATNODEDIR="${STATLOGDIR}/node-${NODE_NUMBER}"
    STATLOGFILE="${STATNODEDIR}/stat.csv"
    mkdir -p "$STATNODEDIR"
    echo "Starting dool monitor in ${NODE}, storing data on ${STATNODEDIR}" >> "${STATLOGDIR}/log" 2>&1

    nohup $SSH_CMD "$NODE" "export STATLOGFILE='${STATLOGFILE}'; \
        export STAT_SECONDS_INTERVAL='${STAT_SECONDS_INTERVAL}'; \
        export PYTHON_BIN='${PYTHON_BIN}'; \
        export DOOL_COMMAND='${DOOL_COMMAND}'; \
        export DOOL_OPTIONS=\"${DOOL_OPTIONS}\"; \
        bash '${STAT_HOME}/stat_monitor.sh'" > "${STATNODEDIR}/stat.out" 2>&1 &

    NODE_NUMBER=$(( NODE_NUMBER + 1 ))
done
