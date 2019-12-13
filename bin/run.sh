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
		# For each solution
		for SOLUTION in $SOLUTIONS
		do
			set_solution

			bash $METHOD_BIN_DIR/run-sol.sh
		done
	fi
done

m_stop_message
