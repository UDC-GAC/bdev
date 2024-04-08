#!/bin/sh

$COMMON_SRC_DIR/bin/start_hadoop_yarn.sh

#Setup local temporary directories on all nodes
rm -rf ${FLINK_LOCAL_DIRS}/*
mkdir -p ${FLINK_LOCAL_DIRS}
for j in `cat ${SLAVESFILE}`; do
        $SSH_CMD $j "rm -rf ${FLINK_LOCAL_DIRS}/*"
        $SSH_CMD $j "mkdir -p ${FLINK_LOCAL_DIRS}"
done

#Save Hadoop classpath to a file
echo $HADOOP_CLASSPATH > $FLINK_HADOOP_CLASSPATH

$FLINK_HOME/bin/start-cluster.sh

if [[ $FLINK_HISTORY_SERVER == "true" ]]
then
        ${HDFS_CMD} ${MKDIR} ${FLINK_HISTORY_SERVER_DIR}
        ${HDFS_CMD} ${CHMOD} 777 ${FLINK_HISTORY_SERVER_DIR}

        #Flink history server
        $FLINK_HOME/bin/historyserver.sh start

        sleep 1
fi

sleep 15
