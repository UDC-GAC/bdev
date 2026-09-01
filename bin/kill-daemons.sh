#!/bin/bash

m_echo "Performing process cleanup"

for SLAVE in $MASTERNODE $SLAVENODES
do
	$SSH_CMD $SLAVE "export JPS=${JPS};\
		export DOOL_COMMAND_NAME=${DOOL_COMMAND_NAME};\
		export PYTHON_BIN=${PYTHON_BIN};\
		$BDEV_BIN_DIR/clean-node-daemons.sh"
done

m_echo "Cleanup done"
