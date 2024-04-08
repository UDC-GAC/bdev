#!/bin/bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
export METHOD_HOME=`cd "$bin"/..; pwd`

# Load BDEv configuration
. $METHOD_HOME/bin/method-env.sh

m_start_message

# Load nodes and IPs
. $METHOD_BIN_DIR/load-nodes.sh

# Init BDEv
. $METHOD_BIN_DIR/init.sh

# For each cluster size
for CLUSTER_SIZE in $CLUSTER_SIZES
do
	set_cluster_size

	if [ -z "$SOLUTIONS" ]; then
		m_echo "No solution was selected. Running in command mode"
		export SOLUTIONS=""
		export SOLUTION=NONE
		export BENCHMARKS=command
		set_nosolution

		bash $METHOD_BIN_DIR/run-nosol.sh
	else
		SOLUTION_NUMBER=0
		export FORCE_DELETE_HDFS=$DELETE_HDFS

		if [[ $NUM_CLUSTERS -gt 1 ]]; then
			export FORCE_DELETE_HDFS=true
		elif [[ $FORMAT_HDFS == "true" ]]; then
			export FORCE_DELETE_HDFS=true
		fi

		. $METHOD_BIN_DIR/delete-nodes-data.sh

		# For each solution
		for SOLUTION in $SOLUTIONS
		do
			set_solution
			SOLUTION_NUMBER=$((SOLUTION_NUMBER+1))
			export FORCE_FORMAT_HDFS=false

			if [[ $SOLUTION_NUMBER -eq 1 ]]; then
				if [[ $FORMAT_HDFS == "true" ]] || [[ $FORCE_DELETE_HDFS == "true" ]]; then
					export FORCE_FORMAT_HDFS=true
				fi
			fi

			bash $METHOD_BIN_DIR/run-sol.sh
		done
	fi
done

# Finish BDEv
. $METHOD_BIN_DIR/finish.sh

m_stop_message
