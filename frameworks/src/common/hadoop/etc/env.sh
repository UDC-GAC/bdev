#!/bin/bash

if [[ -z "${SOLUTION_BENCH_DIR:-}" ]]; then
	# --- Rol: FRAMEWORK PRINCIPAL ---
	export HADOOP_HOME="$SOLUTION_HOME"
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

if [[ -z "${SOLUTION_BENCH_DIR:-}" ]]; then
	# --- Rol: FRAMEWORK PRINCIPAL ---
	export SOLUTION_CONF_DIR_SRC="$HADOOP_CONF_DIR_SRC"
	export SOLUTION_CONF_DIR="$SOLUTION_REPORT_DIR/conf/hadoop"
	export SOLUTION_LOG_DIR="$SOLUTION_REPORT_DIR/logs/hadoop"
	export SOLUTION_LIB_DIR="$SOLUTION_REPORT_DIR/lib"
	export SOLUTION_BENCH_DIR="$BENCHMARKS_DIR/Hadoop"
	export HADOOP_CONF_DIR="$SOLUTION_CONF_DIR"
	export HADOOP_LOG_DIR="$SOLUTION_LOG_DIR"
	export HADOOP_LIB_DIR="$SOLUTION_LIB_DIR"
else
	# --- Rol: COMPONENTE AUXILIAR (Spark / Flink) ---
	export HADOOP_CONF_DIR="$SOLUTION_REPORT_DIR/conf/hadoop"
	export HADOOP_LOG_DIR="$SOLUTION_REPORT_DIR/logs/hadoop"
	export HADOOP_LIB_DIR="$SOLUTION_REPORT_DIR/lib"
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

if [[ -z "${SOLUTION_TEMPLATE_DIR:-}" ]]; then
	# --- Rol: FRAMEWORK PRINCIPAL ---
	export SOLUTION_TEMPLATE_DIR="$HADOOP_TEMPLATE_DIR"
	export WORKERSFILE="$HADOOP_WORKERSFILE"
fi
