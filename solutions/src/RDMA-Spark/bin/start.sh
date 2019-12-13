#!/bin/sh

$COMMON_SRC_DIR/bin/start_hadoop_yarn.sh

#Spark
$COMMON_SRC_DIR/bin/spark-config.sh set

$SPARK_HOME/sbin/start-master.sh &

sleep 10

$SPARK_HOME/sbin/start-slaves.sh &

sleep 10
