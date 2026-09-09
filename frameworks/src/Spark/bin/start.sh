#!/bin/bash

"$COMMON_HADOOP_DIR/bin/start.sh"

if [[ "${RESOURCE_MANAGER:-standalone}" == "standalone" ]]; then
	m_echo "Starting the standalone Spark cluster"
	"$SPARK_HOME/sbin/start-master.sh"
	bash "$FRAMEWORK_DIR/bin/start-workers.sh"
fi

if [[ "$SPARK_HISTORY_SERVER" == "true" ]]; then
	storage_mkdir "$SPARK_HISTORY_SERVER_DIR"
	storage_chmod -R 777 "$SPARK_HISTORY_SERVER_DIR"

	#Spark history server
	"$SPARK_HOME/sbin/start-history-server.sh"
fi
