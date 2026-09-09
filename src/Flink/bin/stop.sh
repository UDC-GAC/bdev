#!/bin/bash

if [[ "${RESOURCE_MANAGER:-standalone}" == "yarn" ]]; then
	echo "stop" | "$FLINK_HOME/bin/yarn-session.sh" -id $YARN_APP_ID
	"$COMMON_HADOOP_DIR/bin/stop.sh"
	return 0
fi

# Avoid cleanup if framework does not exist
SCRIPT_MASTER="$FLINK_HOME/bin/jobmanager.sh"

if [[ -f "$SCRIPT_MASTER" ]]; then
	bash "$SCRIPT_MASTER" stop
	bash "$FRAMEWORK_DIR/bin/stop-workers.sh"
fi

"$COMMON_HADOOP_DIR/bin/stop_hdfs.sh"
bash "$CLEANUP_PROCESS_SCRIPT"
