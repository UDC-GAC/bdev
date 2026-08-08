#!/bin/bash

m_echo "Stopping HDFS services"
"${HADOOP_HOME}/sbin/stop-dfs.sh" --config "${HADOOP_CONF_DIR}"
