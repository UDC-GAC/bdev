#!/bin/bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
export BDEV_HOME=`cd "$bin"/..; pwd`

# Load BDEv configuration
. ${BDEV_HOME}/bin/bdev-env.sh

# Init BDEv
. ${BDEV_BIN_DIR}/init.sh

# For each cluster size
for CLUSTER_SIZE in $CLUSTER_SIZES; do
	set_cluster_size

	if [[ "$NUM_FRAMEWORKS" -eq 0 ]]; then
		set_no_framework
		bash ${BDEV_BIN_DIR}/run-command.sh
	else
		FRAMEWORK_NUMBER=0

		# For each framework
		for FRAMEWORK in $FRAMEWORKS; do
			FRAMEWORK_NUMBER=$((FRAMEWORK_NUMBER+1))
			set_framework $FRAMEWORK_NUMBER
			export FORCE_FORMAT_HDFS=false
			export FORCE_WIPE_HDFS=false

			if [[ $FRAMEWORK_NUMBER -eq 1 ]]; then
				# Only format HDFS at startup if the user requested it or if the cluster size changed
				if [[ $FORMAT_HDFS == "true" || $NUM_CLUSTERS -gt 1 ]]; then
					export FORCE_FORMAT_HDFS=true
					export FORCE_WIPE_HDFS=true
				fi
		    	elif [[ "${STORAGE_BACKEND,,}" == "hdfs" ]]; then
		    		# Subsequent frameworks in the same cluster: format only if Hadoop version changes
				if [[ $LAST_HADOOP_VERSION != "null" && $CURRENT_HADOOP_VERSION != $LAST_HADOOP_VERSION ]]; then
					export FORCE_FORMAT_HDFS=true
					export FORCE_WIPE_HDFS=true
					m_echo "Hadoop version changed ($LAST_HADOOP_VERSION -> $CURRENT_HADOOP_VERSION): Wiping and reformatting HDFS"
				elif [[ "$FORMAT_HDFS" == "true" ]]; then
					# If the user explicitly configured formatting between each framework
					export FORCE_FORMAT_HDFS=true
					export FORCE_WIPE_HDFS=true
				fi
			fi

			# Perform data cleanup before starting the framework
			. $CLEANUP_DATA_SCRIPT -c -m

			if [[ "$NUM_BENCHMARKS" -eq 0 ]]; then
				m_warn "No benchmark was configured. Running in command mode"
				export BENCHMARKS=command
				export NUM_BENCHMARKS=1
			fi

			# Run framework
			bash ${BDEV_BIN_DIR}/run-framework.sh
		done
	fi
done

# Finish BDEv
. ${BDEV_BIN_DIR}/finish.sh
