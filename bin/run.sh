#!/bin/bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
export BDEV_HOME=`cd "$bin"/..; pwd`

# Load BDEv configuration
. $BDEV_HOME/bin/bdev-env.sh

m_start_message

# Init BDEv
. $BDEV_BIN_DIR/init.sh

# For each cluster size
for CLUSTER_SIZE in $CLUSTER_SIZES
do
	set_cluster_size

	if [[ "$NUM_SOLUTIONS" -eq 0 ]]; then
		m_warn "No framework was configured. Running in command mode"
		export SOLUTIONS=""
		export SOLUTION=NONE
		export BENCHMARKS=command
		export NUM_BENCHMARKS=1
		set_nosolution

		bash $BDEV_BIN_DIR/run-nosol.sh
	else
		SOLUTION_NUMBER=0
		export FORCE_DELETE_HDFS=$DELETE_HDFS

		if [[ $NUM_CLUSTERS -gt 1 ]]; then
			export FORCE_DELETE_HDFS=true
		elif [[ $FORMAT_HDFS == "true" ]]; then
			export FORCE_DELETE_HDFS=true
		fi

		. $BDEV_BIN_DIR/delete-nodes-data.sh

		# For each solution
		for SOLUTION in $SOLUTIONS
		do
			SOLUTION_NUMBER=$((SOLUTION_NUMBER+1))
			set_solution $SOLUTION_NUMBER
			export FORCE_FORMAT_HDFS=false

			if [[ $SOLUTION_NUMBER -eq 1 ]]; then
			    if [[ $FORMAT_HDFS == "true" ]] || [[ $FORCE_DELETE_HDFS == "true" ]]; then
				export FORCE_FORMAT_HDFS=true
			    fi
		    	elif [[ $NUM_SOLUTIONS -gt 1 ]]; then
			    if [[ $LAST_HADOOP_VERSION != "null" ]] && [[ $CURRENT_HADOOP_VERSION != $LAST_HADOOP_VERSION ]]; then
				export FORCE_FORMAT_HDFS=true
				m_echo "Previous Hadoop version was $LAST_HADOOP_VERSION"
				m_echo "Current Hadoop version is $CURRENT_HADOOP_VERSION"
				m_echo "HDFS will be formatted due to differences in Hadoop versions"
			    fi
			fi

			if [[ "$NUM_BENCHMARKS" -eq 0 ]]; then
				m_warn "No benchmark was configured. Running in command mode"
				export BENCHMARKS=command
				export NUM_BENCHMARKS=1
			fi

			bash $BDEV_BIN_DIR/run-sol.sh
		done
	fi
done

# Finish BDEv
. $BDEV_BIN_DIR/finish.sh

m_stop_message
