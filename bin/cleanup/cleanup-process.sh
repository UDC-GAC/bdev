#!/bin/bash

m_echo "Performing process cleanup"

for NODE in $MASTERNODE $SLAVENODES
do
	$SSH_CMD $NODE "export JPS=${JPS};\
		export DOOL_COMMAND_NAME=${DOOL_COMMAND_NAME};\
		export PYTHON_BIN=${PYTHON_BIN};\
		$BDEV_CLEANUP_DIR/process.sh"
done

m_echo "Cleanup done"
