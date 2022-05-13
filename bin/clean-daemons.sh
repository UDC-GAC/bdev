#!/bin/sh

sleep 1

for SLAVE in $MASTERNODE $SLAVENODES
do
	ssh $SLAVE "export JPS=${JPS};\
		export TMP_DIR=${TMP_DIR};\
		export LOCAL_DIRS=${LOCAL_DIRS};\
		export DOOL_COMMAND_NAME=${DOOL_COMMAND_NAME};\
		export PYTHON3_BIN=${PYTHON3_BIN};\
		$METHOD_BIN_DIR/clean-node.sh"
done
