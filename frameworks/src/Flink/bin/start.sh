#!/bin/bash

$COMMON_SRC_DIR/bin/start_hadoop_yarn.sh

# Setup required jars
. ${SOL_BENCH_DIR}/conf/setup_jars.sh

#Save Hadoop classpath to a file
echo $HADOOP_CLASSPATH > $FLINK_HADOOP_CLASSPATH

# Create LOG dir
mkdir -p "$FLINK_LOG_DIR" 2>/dev/null || true

m_echo "Starting the standalone Flink cluster (Session Mode)"
$FLINK_HOME/bin/start-cluster.sh

if [ $FLINK_HISTORY_SERVER == "true" ]; then
    storage_mkdir ${FLINK_HISTORY_SERVER_DIR}
	storage_chmod -R 777 ${FLINK_HISTORY_SERVER_DIR}

    #Flink history server
    $FLINK_HOME/bin/historyserver.sh start
fi
