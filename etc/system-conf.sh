#!/bin/bash

## Configuration parameters for the host system characteristics

export TMP_DIR=/tmp		# Directory to store temporary files
export LOCAL_DIRS="$TMP_DIR" 	# Comma-separated list of directories to store local data in each node
export LOOPBACK_IP=127.0.0.1	# IP of the loopback network interface
export ETHERNET_INTERFACE=eth0 	# Ethernet network interface for TCP/IP 
export IPOIB_INTERFACE=ib0 	# Network interface for IP over InfiniBand (IPoIB)
export RDMA_INTERFACE=mlx5_0	# RDMA interface for InfiniBand/RoCE (only for RDMA-Hadoop-3)
export MEMORY_PER_NODE_FACTOR=0.95	# Percentage of the total memory per node available for allocation
export CPUS_PER_NODE=$(grep "^physical id" /proc/cpuinfo | sort -u | wc -l)	# CPUs per node
export CORES_PER_CPU=$(grep "^core id" /proc/cpuinfo | sort -u | wc -l)		# Cores per CPU
export CORES_PER_NODE=$(( $CPUS_PER_NODE * $CORES_PER_CPU ))			# Cores per node
export MEMORY_PER_NODE=$(awk '/^MemTotal:/ {print int($2 / 1024)}' /proc/meminfo)	# Total memory per node
export MEMORY_ALLOC_PER_NODE=$(op_int "$MEMORY_PER_NODE * $MEMORY_PER_NODE_FACTOR")	# Available memory per node
export BDEV_SSH_OPTS="-o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10s -o LogLevel=ERROR"	# SSH options
