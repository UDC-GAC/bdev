#!/bin/bash

sleep 1

for SLAVE in $MASTERNODE $SLAVENODES
do
	$SSH_CMD $SLAVE "export TMP_DIR=${TMP_DIR};\
		export LOCAL_DIRS=${LOCAL_DIRS};\
		export FORCE_DELETE_HDFS=${FORCE_DELETE_HDFS};\
		$BDEV_BIN_DIR/clean-node-data.sh"
done
