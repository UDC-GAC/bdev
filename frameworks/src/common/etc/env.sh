#!/bin/sh

if [ -z "${HADOOP_HOME:-}" ]; then
	m_exit "HADOOP_HOME is not defined or is empty"
fi

if [ ! -d "$HADOOP_HOME" ]; then
	m_exit "HADOOP_HOME does not exist or is not a directory: $HADOOP_HOME"
fi

export HADOOP_CONF_DIR_SRC=$HADOOP_HOME/etc/hadoop
export HADOOP_CONF_DIR=$SOLUTION_REPORT_DIR/conf/hadoop
export HADOOP_LOG_DIR=$SOLUTION_REPORT_DIR/logs/hadoop
export YARN_CONF_DIR=$HADOOP_CONF_DIR
export YARN_LOG_DIR=$SOLUTION_REPORT_DIR/logs/hadoop
export PATH=$HADOOP_HOME/bin:$PATH
export HADOOP_VERSION=${HADOOP_HOME##*/}
export HADOOP_MAJOR_VERSION=${HADOOP_VERSION%.*}
export HADOOP_SERIES=${HADOOP_VERSION%%.*}

if [ $HADOOP_SERIES == "3" ]; then
	export HADOOP_TEMPLATE_DIR=$TEMPLATES_DIR/Hadoop-YARN-3
	export HADOOP_DAEMONS_DIR=$DAEMONS_DIR/Hadoop-YARN-3
	export HADOOP_SBIN_DIR=$HADOOP_HOME/libexec
	export HADOOP_SLAVESFILE=$HADOOP_CONF_DIR/workers
elif [ $HADOOP_SERIES == "2" ]; then
	export HADOOP_TEMPLATE_DIR=$TEMPLATES_DIR/Hadoop-YARN
	export HADOOP_DAEMONS_DIR=$DAEMONS_DIR/Hadoop-YARN
	export HADOOP_SBIN_DIR=$HADOOP_HOME/sbin
	export HADOOP_SLAVESFILE=$HADOOP_CONF_DIR/slaves
else
	m_exit "Hadoop version is not supported: $HADOOP_VERSION"
fi
