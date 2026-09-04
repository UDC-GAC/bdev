#!/bin/bash

kill_java_process() {
    local node="$1"
    local process="$2"

    m_echo "Finishing $process:" "$node"
    $SSH_CMD "$node" \
        "DAEMON_PIDS=\$(\"$JPS\" | awk -v process=\"$process\" '\$2 ~ process {print \$1}'); \
         if [[ -n \"\$DAEMON_PIDS\" ]]; then
             kill -9 \$DAEMON_PIDS 2>/dev/null
         fi"		 
}

if [[ -v FINISH_YARN_FORCE && "$FINISH_YARN_FORCE" == "true" ]]; then
	SLAVES=$(cat "$SLAVESFILE")
	for NODE in $SLAVES; do
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
