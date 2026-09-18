#!/bin/bash

kill_java_process() {
    local process="$1"
    shift
    local target_nodes="$*"

    [[ -z "$process" || -z "$target_nodes" ]] && return 0

    # Deduplicate nodes
    local unique_nodes
    unique_nodes=$(printf '%s\n' $target_nodes | sort -u)

    local kill_tmp_dir
    kill_tmp_dir=$(mktemp -d /tmp/bdev_kill_java_XXXXXX)

    for node in $unique_nodes; do
        (
            local output
            output=$($SSH_CMD "$node" "
                JPS_MATCHES=\$(\"$JPS\" 2>/dev/null | awk -v p=\"$process\" '\$2 ~ p')
                if [[ -n \"\$JPS_MATCHES\" ]]; then
                    PROCESS_PIDS=\$(echo \"\$JPS_MATCHES\" | awk '{print \$1}')
                    echo \"\$HOSTNAME: cleaning up $process\"
                    echo \"\$JPS_MATCHES\" | awk '{printf \"  %s with PID %s\\n\", \$2, \$1}'
                    kill -9 \$PROCESS_PIDS 2>/dev/null || true
                fi" 2>&1)

            echo "$output" > "$kill_tmp_dir/${node}.out"
        ) &
    done

    # Wait for all concurrent processes to finish
	wait

    for node in $unique_nodes; do
        local node_out
        node_out=$(cat "$kill_tmp_dir/${node}.out" 2>/dev/null || true)
        if [[ -n "$node_out" ]]; then
            echo "$node_out"
        fi
    done

    # Cleaning up the local temporary directory
    rm -rf "$kill_tmp_dir"
}

if [[ -v FINISH_YARN_FORCE && "$FINISH_YARN_FORCE" == "true" ]]; then
	WORKERS=$(cat "$WORKERSFILE" 2>/dev/null || true)
	if [[ -n "$WORKERS" ]]; then
		kill_java_process "NodeManager" $WORKERS
	fi

  	kill_java_process "ResourceManager" "$MASTERNODE"

  	if [[ $TIMELINE_SERVER == "true" ]]; then
		kill_java_process "ApplicationHistoryServer" "$MASTERNODE"
	fi
else
	m_echo "Stopping YARN services"
	"${HADOOP_HOME}/sbin/stop-yarn.sh" --config "${HADOOP_CONF_DIR}"
fi

if [[ $MR_JOBHISTORY_SERVER == "true" ]]; then
	kill_java_process "JobHistoryServer" "$MASTERNODE"
fi
