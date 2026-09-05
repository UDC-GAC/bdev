#!/bin/bash

m_echo "Performing process cleanup"

for NODE in $MASTERNODE $WORKERNODES
do
	$SSH_CMD $NODE "export USER='${USER}';\
		export JPS=${JPS};\
		export DOOL_COMMAND_NAME=${DOOL_COMMAND_NAME};\
		export PYTHON_BIN=${PYTHON_BIN};\
		$HELPER_SCRIPTS_DIR/kill-process.sh"
done

m_echo "Cleanup done"
