#!/bin/sh

$COMMON_SRC_DIR/bin/start_hadoop_yarn.sh

m_echo "Starting the standalone Spark cluster"
$SPARK_HOME/sbin/start-master.sh
$SPARK_WORKERS_START_SCRIPT

if [[ $SPARK_HISTORY_SERVER == "true" ]]
then
	${HDFS_CMD} ${MKDIR} ${SPARK_HISTORY_SERVER_DIR}
	${HDFS_CMD} ${CHMOD} 777 ${SPARK_HISTORY_SERVER_DIR}

    #Spark history server
	$SPARK_HOME/sbin/start-history-server.sh
fi
