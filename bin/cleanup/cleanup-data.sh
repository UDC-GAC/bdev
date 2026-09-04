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

if [[ "$DISK_SPACE_CHECK" == "true" ]]; then
	m_echo "Performing data cleanup and disk space checks (threshold: ${DISK_SPACE_THRESHOLD}%)"
else
	m_echo "Performing data cleanup"
fi

for NODE in $MASTERNODE $SLAVENODES
do
	$SSH_CMD $NODE "export USER='${USER}';\
		export TMP_DIR=${TMP_DIR};\
		export LOCAL_DIRS='${LOCAL_DIRS}';\
		export SPARK_LOCAL_DIRS='${SPARK_LOCAL_DIRS}';\
		export FLINK_LOCAL_DIRS='${FLINK_LOCAL_DIRS}';\
		export FORCE_DELETE_HDFS=${FORCE_DELETE_HDFS};\
		export DISK_SPACE_CHECK=${DISK_SPACE_CHECK};\
		export DISK_SPACE_THRESHOLD=${DISK_SPACE_THRESHOLD};\
		export BDEV_BIN_DIR=${BDEV_BIN_DIR};\
		export REPORT_LOG=${REPORT_LOG};\
		$HELPER_SCRIPTS_DIR/clean-data.sh"
done

m_echo "Cleanup done"
