#!/bin/bash

m_echo "Performing data cleanup"

for SLAVE in $MASTERNODE $SLAVENODES
do
	$SSH_CMD $SLAVE "export TMP_DIR=${TMP_DIR};\
		export LOCAL_DIRS='${LOCAL_DIRS}';\
		export SPARK_LOCAL_DIRS='${SPARK_LOCAL_DIRS}';\
		export FLINK_LOCAL_DIRS='${FLINK_LOCAL_DIRS}';\
		export FORCE_DELETE_HDFS=${FORCE_DELETE_HDFS};\
		$BDEV_CLEANUP_DIR/data.sh"
done

m_echo "Cleanup done"
