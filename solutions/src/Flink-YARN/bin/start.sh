#!/bin/sh

$COMMON_SRC_DIR/bin/start_hadoop_yarn.sh

#Setup temporary directories on taskmanagers
for j in `cat ${FLINK_CONF_DIR}/slaves`; do
        ssh $j "mkdir -p ${FLINK_TASKMANAGER_TMP_DIRS}"
done
