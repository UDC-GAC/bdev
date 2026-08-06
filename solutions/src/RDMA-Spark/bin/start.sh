#!/bin/sh

$COMMON_SRC_DIR/bin/start_hadoop_yarn.sh

m_echo "Starting the standalone Spark cluster"
$SPARK_HOME/sbin/start-master.sh &

sleep 5

$SPARK_HOME/sbin/start-slaves.sh &

sleep 10
