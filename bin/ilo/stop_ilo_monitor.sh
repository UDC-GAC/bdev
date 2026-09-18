#!/bin/bash

if [[ "$ILO_MASTER" == "localhost" || -z "$ILO_MASTER" ]]; then
    export ILO_MASTER="$MASTERNODE"
fi

m_echo "Stopping iLO monitors on $ILO_MASTER"
echo "Stopping iLO monitors on $ILO_MASTER" >> "${POWERLOGDIR}/log" 2>&1

$SSH_CMD "$ILO_MASTER" "pkill -9 -f 'ilo_monitor.sh' 2>/dev/null || true" >> "${POWERLOGDIR}/log" 2>&1
