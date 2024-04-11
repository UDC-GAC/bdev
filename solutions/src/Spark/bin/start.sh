#!/bin/sh

$COMMON_SRC_DIR/bin/start_hadoop_yarn.sh

$SPARK_HOME/sbin/start-master.sh &

sleep 5

$SPARK_HOME/sbin/start-slaves.sh &

if [[ $SPARK_HISTORY_SERVER == "true" ]]
then
	${HDFS_CMD} ${MKDIR} ${SPARK_HISTORY_SERVER_DIR}
	${HDFS_CMD} ${CHMOD} 777 ${SPARK_HISTORY_SERVER_DIR}

        #Spark history server
	$SPARK_HOME/sbin/start-history-server.sh &
fi

sleep 10
