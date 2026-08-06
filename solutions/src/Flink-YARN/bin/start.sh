#!/bin/sh

$COMMON_SRC_DIR/bin/start_hadoop_yarn.sh

#Setup local temporary directories on all nodes
rm -rf ${YARN_PROPS_FILE_CUSTOM} ${YARN_PROPS_FILE_DEFAULT}
rm -rf ${FLINK_LOCAL_DIRS}/*
mkdir -p ${FLINK_LOCAL_DIRS}
for j in `cat ${SLAVESFILE}`; do
 	$SSH_CMD $j "rm -rf ${FLINK_LOCAL_DIRS}/*"
        $SSH_CMD $j "mkdir -p ${FLINK_LOCAL_DIRS}"
done

#Save Hadoop classpath to a file
echo $HADOOP_CLASSPATH > $FLINK_HADOOP_CLASSPATH

m_echo "Starting the Flink cluster on YARN (Session Mode)"
$FLINK_HOME/bin/yarn-session.sh -d \
	-jm $FLINK_YARN_JOBMANAGER_MEMORY \
	-tm $FLINK_YARN_TASKMANAGER_MEMORY \
	-s $FLINK_TASKMANAGER_SLOTS

if [ $? -ne 0 ]; then
	m_exit "yarn-session.sh failed"
fi

sleep 1

if [ -f "$YARN_PROPS_FILE_CUSTOM" ]; then
	export YARN_APP_ID=$(grep applicationID "$YARN_PROPS_FILE_CUSTOM" | cut -d'=' -f2)
elif [ -f "$YARN_PROPS_FILE_DEFAULT" ]; then
	export YARN_APP_ID=$(grep applicationID "$YARN_PROPS_FILE_DEFAULT" | cut -d'=' -f2)
else
	m_warn "File .yarn-properties not found. Querying YARN..."
	export YARN_APP_ID=$("$YARN_EXECUTABLE" application -list -appStates RUNNING,ACCEPTED 2>/dev/null | grep "application_" | awk '{print $1}' | head -n 1)
fi

if [ -z "$YARN_APP_ID" ]; then
	FILE_CONTENT=$(cat $YARN_PROPS_FILE)
	m_exit "YARN appID could not be obtained"
fi

m_echo "YARN appID session: $YARN_APP_ID"
export DEPLOY_ARGS="$DEPLOY_ARGS -Dyarn.application.id=$YARN_APP_ID"

if [[ $FLINK_HISTORY_SERVER == "true" ]]
then
        ${HDFS_CMD} ${MKDIR} ${FLINK_HISTORY_SERVER_DIR}
        ${HDFS_CMD} ${CHMOD} 777 ${FLINK_HISTORY_SERVER_DIR}

        #Flink history server
        $FLINK_HOME/bin/historyserver.sh start

        sleep 5
fi
