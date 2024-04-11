#!/bin/sh

mkdir -p $POWERLOGDIR

if [[ $ILO_MASTER == "localhost" ]]
then
        export ILO_MASTER=$MASTERNODE
fi

m_echo "iLO master: $ILO_MASTER"

nohup $SSH_CMD $ILO_MASTER \
"export POWERLOGDIR='$POWERLOGDIR';\
export SLAVES='$SLAVENODES';\
export MASTERNODE='$MASTERNODE';\
export ILO_HOME='$ILO_HOME';\
export ILO_POWER_SCRIPT='$ILO_POWER_SCRIPT';\
export ILO_CONFIG_SCRIPT='$ILO_CONFIG_SCRIPT';\
export ILO_SECONDS_INTERVAL='$ILO_SECONDS_INTERVAL';\
export ILO_BASE_IP='$ILO_BASE_IP';\
bash $ILO_HOME/create_ilo_monitors.sh" >/dev/null 2>&1 &
