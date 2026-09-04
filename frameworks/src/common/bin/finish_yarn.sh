#!/bin/bash

kill_java_process() {
    local node="$1"
    local process="$2"

    m_echo "Finishing $process:" "$node"
    $SSH_CMD "$node" "${BDEV_BIN_DIR}/kill.sh $JPS $process"
}

if [[ -v FINISH_YARN_FORCE && "$FINISH_YARN_FORCE" == "true" ]]; then
	SLAVES=$(cat "$SLAVESFILE")
	for NODE in $SLAVES; do
		kill_process "$NODE" "NodeManager"
	done

  	kill_process "$MASTERNODE" "ResourceManager"

  	if [[ $TIMELINE_SERVER == "true" ]]; then
		kill_process "$MASTERNODE" "ApplicationHistoryServer"
	fi
else
	m_echo "Stopping YARN services"
	"${HADOOP_HOME}/sbin/stop-yarn.sh" --config "${HADOOP_CONF_DIR}"
fi

if [[ $MR_JOBHISTORY_SERVER == "true" ]]; then
	kill_process "$MASTERNODE" "JobHistoryServer"
fi
