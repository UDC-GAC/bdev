#!/bin/sh

$COMMON_SRC_DIR/bin/start_hadoop_yarn.sh

$COMMON_SRC_DIR/bin/flink-config.sh

#Setup temporary directories on taskmanagers
for j in `cat ${FLINK_CONF_DIR}/slaves`; do
        ssh $j "rm -rf ${FLINK_TASKMANAGER_TMP_DIRS}/*"
        ssh $j "mkdir -p ${FLINK_TASKMANAGER_TMP_DIRS}"
done

$FLINK_HOME/bin/start-cluster.sh

sleep 20
