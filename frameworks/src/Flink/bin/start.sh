#!/bin/bash

$COMMON_SRC_DIR/bin/start_hadoop_yarn.sh

#Setup local temporary directories on all nodes
rm -rf ${FLINK_LOCAL_DIRS}/*
mkdir -p ${FLINK_LOCAL_DIRS}
for j in `cat ${SLAVESFILE}`; do
        $SSH_CMD $j "rm -rf ${FLINK_LOCAL_DIRS}/*"
        $SSH_CMD $j "mkdir -p ${FLINK_LOCAL_DIRS}"
done

# Setup required jars
. ${SOL_BENCH_DIR}/conf/setup_jars.sh

#Save Hadoop classpath to a file
echo $HADOOP_CLASSPATH > $FLINK_HADOOP_CLASSPATH

m_echo "Starting the standalone Flink cluster (Session Mode)"
$FLINK_HOME/bin/start-cluster.sh

if [ $FLINK_HISTORY_SERVER == "true" ]; then
    storage_mkdir ${FLINK_HISTORY_SERVER_DIR}
	storage_chmod -R 777 ${FLINK_HISTORY_SERVER_DIR}

    #Flink history server
    $FLINK_HOME/bin/historyserver.sh start
fi
