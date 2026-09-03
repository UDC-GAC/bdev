#!/bin/bash

if [[ "${STORAGE_BACKEND,,}" == "hdfs" ]]; then
  m_echo "Stopping HDFS services"
  "${HADOOP_HOME}/sbin/stop-dfs.sh" --config "${HADOOP_CONF_DIR}"
fi
