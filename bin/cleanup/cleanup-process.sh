#!/bin/bash

m_echo "Performing process cleanup"

# Deduplicate nodes in case the master is also a worker
UNIQUE_NODES=$(printf '%s\n' $MASTERNODE $WORKERNODES | sort -u)

for NODE in $UNIQUE_NODES; do
	$SSH_CMD "$NODE" "export USER='${USER}'; \
        	export JPS='${JPS}'; \
        	export DOOL_COMMAND_NAME='${DOOL_COMMAND_NAME}'; \
        	export PYTHON_BIN='${PYTHON_BIN}'; \
        	export ENABLE_OPROFILE='${ENABLE_OPROFILE:-}'; \
        	export ENABLE_RAPL='${ENABLE_RAPL:-}'; \
        	export OPROFILE_BIN='${OPROFILE_BIN:-}'; \
        	'$HELPER_SCRIPTS_DIR/kill-process.sh'" || true
done

m_echo "Cleanup done"
