#!/bin/bash

# Copy configuration files for YARN schedulers
for F in "$BDEV_CONF_DIR"/yarn/*.xml; do
    [[ -f "$F" ]] || continue
    cp "$F" "$HADOOP_CONF_DIR" || exit 1
done

if [[ $HADOOP_SERIES == "3" ]]; then
	$COMMON_SRC_DIR/bin/start_hadoop_yarn_3.sh
else
	$COMMON_SRC_DIR/bin/start_hadoop_yarn_2.sh
fi

sleep 2

SAFEMODE_STATUS=$($HADOOP_HOME/bin/hdfs dfsadmin -safemode get 2>/dev/null)

if [[ "$SAFEMODE_STATUS" == *"ON"* ]]; then
	m_echo "HDFS is in Safe Mode. Waiting for DataNodes..."
	$HADOOP_HOME/bin/hdfs dfsadmin -safemode wait >/dev/null 2>&1
	m_echo "HDFS has exited the Safe Mode and is ready for writing"
fi
