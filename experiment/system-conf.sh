#!/bin/sh
#
### Configuration parameters for the host system characteristics
#
#export TMP_DIR=/tmp/$USER/$METHOD_NAME	# Directory to store temporary files
#export LOCAL_DIRS="" 		# Comma-separated list of directories to store local data in each node
#export ETH_INTERFACE=eth0 	# Ethernet interface to use in the nodes
#export IPOIB_INTERFACE=ib0 	# IPoIB interface to use in the nodes
#export CPUS_PER_NODE=`grep "^physical id" /proc/cpuinfo | sort -u | wc -l`	# CPUs per node
#export CORES_PER_CPU=`grep "^core id" /proc/cpuinfo | sort -u | wc -l`	# Cores per CPU
#export CORES_PER_NODE=$(( $CPUS_PER_NODE * $CORES_PER_CPU ))	# Cores per node
#export MEMORY_PER_NODE=$((`grep MemTotal /proc/meminfo | awk '{print $2}'`/1024))	# Total Memory per node
#export MEMORY_PER_NODE_FACTOR=0.95	# Percentage of the total memory per node available for allocation
#export MEMORY_ALLOC_PER_NODE=`op_int "$MEMORY_PER_NODE * $MEMORY_PER_NODE_FACTOR"`	# Memory per node available for allocation
#export ENABLE_MODULES=false 	# Enable use of modules environment
#export MODULE_JAVA=java 	# Java module
#export MODULE_MPI=mvapich2 	# MPI module
#export PYTHON3_BIN=python3	# Executable name for Python 3
