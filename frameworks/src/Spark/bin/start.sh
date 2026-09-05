#!/bin/bash

$COMMON_SRC_DIR/bin/start_hadoop_yarn.sh

m_echo "Starting the standalone Spark cluster"
$SPARK_HOME/sbin/start-master.sh
$SPARK_WORKERS_START_SCRIPT --config "$SPARK_CONF_DIR"

if [ $SPARK_HISTORY_SERVER == "true" ]; then
	storage_mkdir ${SPARK_HISTORY_SERVER_DIR}
	storage_chmod -R 777 ${SPARK_HISTORY_SERVER_DIR}

    #Spark history server
	$SPARK_HOME/sbin/start-history-server.sh
fi
