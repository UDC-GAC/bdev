#!/bin/bash

if [[ -z "${FRAMEWORK_BENCH_DIR:-}" ]]; then
	# --- Rol: FRAMEWORK PRINCIPAL ---
	export HADOOP_HOME="$FRAMEWORK_HOME"
else
	# --- Rol: COMPONENTE AUXILIAR (Spark / Flink) ---
	if [[ -z "${HADOOP_HOME:-}" ]]; then
        	m_exit "HADOOP_HOME is not defined"
    	fi
fi

if [[ ! -d "$HADOOP_HOME" ]]; then
    m_exit "HADOOP_HOME does not exist or is not a directory: $HADOOP_HOME"
fi

export HADOOP_CONF_DIR_SRC="$HADOOP_HOME/etc/hadoop"

if [[ -z "${FRAMEWORK_BENCH_DIR:-}" ]]; then
	# --- Rol: FRAMEWORK PRINCIPAL ---
	export FRAMEWORK_CONF_DIR_SRC="$HADOOP_CONF_DIR_SRC"
	export FRAMEWORK_CONF_DIR="$FRAMEWORK_REPORT_DIR/conf/hadoop"
	export FRAMEWORK_LOG_DIR="$FRAMEWORK_REPORT_DIR/logs/hadoop"
	export FRAMEWORK_LIB_DIR="$FRAMEWORK_REPORT_DIR/lib/hadoop"
	export FRAMEWORK_BENCH_DIR="$BENCHMARKS_DIR/Hadoop"
	export HADOOP_CONF_DIR="$FRAMEWORK_CONF_DIR"
	export HADOOP_LOG_DIR="$FRAMEWORK_LOG_DIR"
	export HADOOP_LIB_DIR="$FRAMEWORK_LIB_DIR"
else
	# --- Rol: COMPONENTE AUXILIAR (Spark / Flink) ---
	export HADOOP_CONF_DIR="$FRAMEWORK_REPORT_DIR/conf/hadoop"
	export HADOOP_LOG_DIR="$FRAMEWORK_REPORT_DIR/logs/hadoop"
	export HADOOP_LIB_DIR="$FRAMEWORK_REPORT_DIR/lib/hadoop"
fi

export PATH="$HADOOP_HOME/bin:$PATH"
export HADOOP_SSH_OPTS="${BDEV_SSH_OPTS}"
export HADOOP_VERSION="${HADOOP_HOME##*/}"
export HADOOP_MAJOR_VERSION="${HADOOP_VERSION%.*}"
export HADOOP_SERIES="${HADOOP_VERSION%%.*}"

if [[ "$HADOOP_SERIES" == "3" ]]; then
	export HADOOP_TEMPLATE_DIR="$TEMPLATES_DIR/Hadoop-YARN-3"
	export HADOOP_WORKERSFILE="$HADOOP_CONF_DIR/workers"
elif [[ "$HADOOP_SERIES" == "2" ]]; then
	export HADOOP_TEMPLATE_DIR="$TEMPLATES_DIR/Hadoop-YARN"
	export HADOOP_WORKERSFILE="$HADOOP_CONF_DIR/slaves"
	export YARN_CONF_DIR="$HADOOP_CONF_DIR"
	export YARN_LOG_DIR="$HADOOP_LOG_DIR"
else
    m_exit "Hadoop version is not supported: $HADOOP_VERSION"
fi

if [[ -z "${FRAMEWORK_TEMPLATE_DIR:-}" ]]; then
	# --- Rol: FRAMEWORK PRINCIPAL ---
	export FRAMEWORK_TEMPLATE_DIR="$HADOOP_TEMPLATE_DIR"
	export WORKERSFILE="$HADOOP_WORKERSFILE"
fi
