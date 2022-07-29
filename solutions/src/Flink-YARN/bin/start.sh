#!/bin/sh

$COMMON_SRC_DIR/bin/start_hadoop_yarn.sh

#Setup local temporary directories on all nodes
rm -rf ${FLINK_LOCAL_DIRS}/*
mkdir -p ${FLINK_LOCAL_DIRS}
for j in `cat ${SLAVESFILE}`; do
 	ssh $j "rm -rf ${FLINK_LOCAL_DIRS}/*"
        ssh $j "mkdir -p ${FLINK_LOCAL_DIRS}"
done

#Save Hadoop classpath to a file
echo $HADOOP_CLASSPATH > $FLINK_HADOOP_CLASSPATH

if [[ $FLINK_HISTORY_SERVER == "true" ]]
then
        $HADOOP_EXECUTABLE fs ${MKDIR} ${FLINK_HISTORY_SERVER_DIR}
        $HADOOP_EXECUTABLE fs ${CHMOD} 777 ${FLINK_HISTORY_SERVER_DIR}

        #Flink history server
        $FLINK_HOME/bin/historyserver.sh start

        sleep 5
fi
