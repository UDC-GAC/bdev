#!/bin/bash

m_echo "Performing process cleanup"

# Deduplicate nodes in case the master is also a worker
UNIQUE_NODES=$(printf '%s\n' $MASTERNODE $WORKERNODES | sort -u)

cleanup_pids_failed_nodes=()

for NODE in $UNIQUE_NODES; do
	NODE_OUTPUT=$($SSH_CMD "$NODE" "export USER='${USER}'; \
		export JPS='${JPS}'; \
		export DOOL_COMMAND_NAME='${DOOL_COMMAND_NAME:-}'; \
		export PYTHON_BIN='${PYTHON_BIN:-}'; \
		export ENABLE_OPROFILE='${ENABLE_OPROFILE:-}'; \
		export ENABLE_RAPL='${ENABLE_RAPL:-}'; \
		export OPROFILE_BIN='${OPROFILE_BIN:-}'; \
		'$HELPER_SCRIPTS_DIR/kill-process.sh'" 2>&1)
    	
    	NODE_STATUS=$?
    	if [[ $NODE_STATUS -ne 0 ]]; then
        	m_warn "Process cleanup encountered an error on $NODE (exit code $NODE_STATUS)"
        	[[ -n "$NODE_OUTPUT" ]] && echo "$NODE_OUTPUT" >&2
        	cleanup_pids_failed_nodes+=("$NODE")
    	elif [[ -n "$NODE_OUTPUT" ]]; then
        	echo "$NODE_OUTPUT"
    	fi
	$SSH_CMD "$NODE" "export USER='${USER}'; \
        	export JPS='${JPS}'; \
        	export DOOL_COMMAND_NAME='${DOOL_COMMAND_NAME}'; \
        	export PYTHON_BIN='${PYTHON_BIN}'; \
        	export ENABLE_OPROFILE='${ENABLE_OPROFILE:-}'; \
        	export ENABLE_RAPL='${ENABLE_RAPL:-}'; \
        	export OPROFILE_BIN='${OPROFILE_BIN:-}'; \
        	'$HELPER_SCRIPTS_DIR/kill-process.sh'" || true
done

if [[ ${#cleanup_pids_failed_nodes[@]} -gt 0 ]]; then
    m_warn "Process cleanup finished with warnings on nodes: ${cleanup_pids_failed_nodes[*]}"
fi
