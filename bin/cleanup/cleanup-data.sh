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
	RESULT=$(
		$SSH_CMD $NODE "export USER='${USER}';\
			export TMP_DIR=${TMP_DIR};\
			export LOCAL_DIRS='${LOCAL_DIRS}';\
			export SPARK_LOCAL_DIRS='${SPARK_LOCAL_DIRS}';\
			export FLINK_LOCAL_DIRS='${FLINK_LOCAL_DIRS}';\
			export FORCE_DELETE_HDFS=${FORCE_DELETE_HDFS};\
			export DISK_SPACE_CHECK=${DISK_SPACE_CHECK};\
			export DISK_SPACE_THRESHOLD=${DISK_SPACE_THRESHOLD};\
			$HELPER_SCRIPTS_DIR/clean-data.sh"
	)
done

STATUS=$?

if [[ $STATUS -ne 0 ]]; then
    m_err "Failed cleanup data on $NODE"
elif [[ -n "$RESULT" ]]; then
        echo "$RESULT"
else
	m_echo "Cleanup done"
fi
