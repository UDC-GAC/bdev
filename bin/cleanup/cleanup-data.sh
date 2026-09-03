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

m_echo "Performing data cleanup"

for NODE in $MASTERNODE $SLAVENODES
do
	$SSH_CMD $NODE "export TMP_DIR=${TMP_DIR};\
		export LOCAL_DIRS='${LOCAL_DIRS}';\
		export SPARK_LOCAL_DIRS='${SPARK_LOCAL_DIRS}';\
		export FLINK_LOCAL_DIRS='${FLINK_LOCAL_DIRS}';\
		export FORCE_DELETE_HDFS=${FORCE_DELETE_HDFS};\
		export DISK_SPACE_CHECK=${DISK_SPACE_CHECK};\
		export DISK_SPACE_THRESHOLD=${DISK_SPACE_THRESHOLD};\
		export BDEV_BIN_DIR=${BDEV_BIN_DIR};\
		export REPORT_LOG=${REPORT_LOG};\
		$BDEV_CLEANUP_DIR/data.sh"
done

m_echo "Cleanup done"
