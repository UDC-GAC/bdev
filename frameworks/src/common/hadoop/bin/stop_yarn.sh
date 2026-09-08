#!/bin/bash

kill_java_process() {
    local node="$1"
    local process="$2"

    m_echo "Stopping $process:" "$node"
    $SSH_CMD "$node" "
        JPS_MATCHES=\$(\"$JPS\" 2>/dev/null | awk -v p=\"$process\" '\$2 ~ p')
        if [[ -n \"\$JPS_MATCHES\" ]]; then
            PROCESS_PIDS=\$(echo \"\$JPS_MATCHES\" | awk '{print \$1}')
            echo \"\$HOSTNAME: cleaning up\"
            echo \"\$JPS_MATCHES\" | awk '{printf \"  %s with PID %s\\n\", \$2, \$1}'
            kill -9 \$PROCESS_PIDS 2>/dev/null || true
        fi"	 
}

if [[ -v FINISH_YARN_FORCE && "$FINISH_YARN_FORCE" == "true" ]]; then
	WORKERS=$(cat "$WORKERSFILE")
	for NODE in $WORKERS; do
		kill_java_process "$NODE" "NodeManager"
	done

  	kill_java_process "$MASTERNODE" "ResourceManager"

  	if [[ $TIMELINE_SERVER == "true" ]]; then
		kill_java_process "$MASTERNODE" "ApplicationHistoryServer"
	fi
else
	m_echo "Stopping YARN services"
	"${HADOOP_HOME}/sbin/stop-yarn.sh" --config "${HADOOP_CONF_DIR}"
fi

if [[ $MR_JOBHISTORY_SERVER == "true" ]]; then
	kill_java_process "$MASTERNODE" "JobHistoryServer"
fi
