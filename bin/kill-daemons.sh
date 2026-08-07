#!/bin/sh

m_echo "Performing Java process cleanup"

for SLAVE in $MASTERNODE $SLAVENODES
do
	$SSH_CMD $SLAVE "export JPS=${JPS};\
		export DOOL_COMMAND_NAME=${DOOL_COMMAND_NAME};\
		export PYTHON3_BIN=${PYTHON3_BIN};\
		$METHOD_BIN_DIR/clean-node-daemons.sh"
done
