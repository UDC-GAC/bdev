#!/bin/bash

if [[ "${RESOURCE_MANAGER:-standalone}" == "yarn" ]]; then
	"$COMMON_HADOOP_DIR/bin/stop.sh"
	return 0
fi

# Avoid cleanup if framework does not exist
SCRIPT_MASTER="$SPARK_HOME/sbin/stop-master.sh"

if [[ -f "$SCRIPT_MASTER" ]]; then
	bash "$SCRIPT_MASTER"
	bash "$FRAMEWORK_DIR/bin/stop-workers.sh"
fi

"$COMMON_HADOOP_DIR/bin/stop_hdfs.sh"
bash "$CLEANUP_PROCESS_SCRIPT"

# Get rid of jar files in user logs
find "$SPARK_LOG_DIR" \
    -name "*${SPARK_SCALA_VERSION}.jar" \
    -type f \
    -delete
