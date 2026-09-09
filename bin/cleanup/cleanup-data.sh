#!/bin/bash

DISK_SPACE_CHECK="false"

for arg in "$@"; do
    case "$arg" in
        --check-disk|-c)
            DISK_SPACE_CHECK="true"
            break
            ;;
    esac
done

if [[ "$DISK_SPACE_CHECK" == "true" ]]; then
	m_echo "Performing data cleanup and disk space checks (threshold: ${DISK_SPACE_THRESHOLD}%)"
else
	m_echo "Performing data cleanup"
fi

# Deduplicate nodes in case the master is also a worker
UNIQUE_NODES=$(printf '%s\n' $MASTERNODE $WORKERNODES | sort -u)

for NODE in $UNIQUE_NODES; do
	NODE_RESULT=$($SSH_CMD $NODE "export USER='${USER}';\
		export TMP_DIR='${TMP_DIR:-}'; \
         	export LOCAL_DIRS='${LOCAL_DIRS:-}'; \
         	export SPARK_LOCAL_DIRS='${SPARK_LOCAL_DIRS:-}'; \
         	export FLINK_LOCAL_DIRS='${FLINK_LOCAL_DIRS:-}'; \
         	export FORCE_DELETE_HDFS='${FORCE_DELETE_HDFS:-}'; \
         	export DISK_SPACE_CHECK='${DISK_SPACE_CHECK:-}'; \
         	export DISK_SPACE_THRESHOLD='${DISK_SPACE_THRESHOLD:-}'; \
         	'$HELPER_SCRIPTS_DIR/clean-data.sh'" 2>&1)
	
	NODE_STATUS=$?
	
	if [[ $NODE_STATUS -ne 0 ]]; then
        	m_error "Failed cleanup data on $NODE (exit code $NODE_STATUS)"
        	[[ -n "$NODE_RESULT" ]] && echo "$NODE_RESULT" >&2
        	cleanup_failed_nodes+=("$NODE")
    	elif [[ -n "$NODE_RESULT" ]]; then
        	echo "$NODE_RESULT"
    	fi
done

if [[ ${#cleanup_failed_nodes[@]} -gt 0 ]]; then
    m_error "Data cleanup failed on nodes: ${cleanup_failed_nodes[*]}"
else
    m_echo "Cleanup done"
fi
