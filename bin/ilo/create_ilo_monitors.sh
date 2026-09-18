#!/bin/bash

mkdir -p "$POWERLOGDIR"

echo "Creating ilo_monitor in ${MASTERNODE}, storing data on ${POWERLOGDIR}/node-0.pow" >> "${POWERLOGDIR}/log" 2>&1
bash "${ILO_HOME}/ilo_monitor.sh" "$MASTERNODE" 0 > "${POWERLOGDIR}/node-0.pow" 2>&1 &

node_number=1
for node in $WORKERNODES; do
    # Deduplicate nodes
    [[ "$node" == "$MASTERNODE" ]] && continue

    echo "Creating ilo_monitor in ${node}, storing data on ${POWERLOGDIR}/node-${node_number}.pow" >> "${POWERLOGDIR}/log" 2>&1
    bash "${ILO_HOME}/ilo_monitor.sh" "$node" "$node_number" > "${POWERLOGDIR}/node-${node_number}.pow" 2>&1 &
    
    ((node_number++))
done
