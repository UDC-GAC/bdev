#!/bin/sh

$COMMON_SRC_DIR/bin/start_hadoop_yarn.sh

#Setup local temporary directories on all nodes
rm -rf ${FLINK_LOCAL_DIRS}/*
mkdir -p ${FLINK_LOCAL_DIRS}
for j in `cat ${FLINK_CONF_DIR}/slaves`; do
        ssh $j "rm -rf ${FLINK_LOCAL_DIRS}/*"
        ssh $j "mkdir -p ${FLINK_LOCAL_DIRS}"
done

$FLINK_HOME/bin/start-cluster.sh

sleep 15
