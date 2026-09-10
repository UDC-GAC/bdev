#!/bin/bash

# Copy configuration files for YARN schedulers
for F in "$BDEV_CONF_DIR"/yarn/*.xml; do
    [[ -f "$F" ]] || continue
    cp "$F" "$HADOOP_CONF_DIR" || exit 1
done

# Avoid warnings
mkdir -p "$HADOOP_LOG_DIR" 2>/dev/null || true

# Inyect custom dependencies
inject_custom_dependencies "hadoop" "$HADOOP_LIB_DIR" "${HADOOP_CUSTOM_JARS:-}"

if [[ "$HADOOP_SERIES" == "3" ]]; then
	"$COMMON_HADOOP_DIR/bin/start_yarn_3.sh"
else
	"$COMMON_HADOOP_DIR/bin/start_yarn_2.sh"
fi

sleep 2

SAFEMODE_STATUS=$($HADOOP_HOME/bin/hdfs dfsadmin -safemode get 2>/dev/null)

if [[ "$SAFEMODE_STATUS" == *"ON"* ]]; then
	m_echo "HDFS is in Safe Mode. Waiting for DataNodes..."
	"$HADOOP_HOME/bin/hdfs" dfsadmin -safemode wait >/dev/null 2>&1
	m_echo "HDFS has exited the Safe Mode and is ready for writing"
fi
