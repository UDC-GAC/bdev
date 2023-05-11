#!/bin/sh

## Configuration parameters for Hadoop YARN

export APP_MASTER_HEAPSIZE=1024	# Application Master heapsize (MB)
export APP_MASTER_MEMORY_OVERHEAD=`op_int "$APP_MASTER_HEAPSIZE * 0.1"`	# Overhead of the Application Master memory not allocated to heap
export APP_MASTER_MEMORY_OVERHEAD=$(($APP_MASTER_MEMORY_OVERHEAD>384?$APP_MASTER_MEMORY_OVERHEAD:384))
export APP_MASTER_MEMORY=`op_int "$APP_MASTER_HEAPSIZE + $APP_MASTER_MEMORY_OVERHEAD"` # Application Master memory
export RESOURCEMANAGER_D_HEAPSIZE=1024	# ResourceManager daemon heapsize (MB)
export NODEMANAGER_D_HEAPSIZE=1024	# NodeManager daemon heapsize (MB)
export NODEMANAGER_VCORES=$CORES_PER_NODE	# Number of cores per NodeManager
export NODEMANAGER_MEMORY=`op_int "$MEMORY_ALLOC_PER_NODE - $NODEMANAGER_D_HEAPSIZE - $DATANODE_D_HEAPSIZE"`	# Memory available per NodeManager
export CONTAINER_MEMORY=`op_int "($NODEMANAGER_MEMORY - $APP_MASTER_MEMORY) / $NODEMANAGER_VCORES"`	# Memory per YARN container
export NODEMANAGER_MIN_ALLOCATION=256		# Minimum memory allocation for containers (MB)
export NODEMANAGER_INCREMENT_ALLOCATION=128	# Container memory allocations are rounded up to the nearest multiple of this number (MB)
export NODEMANAGER_PMEM_CHECK=true		# Whether physical memory limits will be enforced for containers
export NODEMANAGER_VMEM_CHECK=false		# Whether virtual memory limits will be enforced for containers
export NODEMANAGER_VMEM_PMEM_RATIO=2.1		# Ratio between virtual to physical memory when setting virtual memory limits for containers
export NODEMANAGER_DISK_HEALTH_CHECKER=true     # Enable or disable the disk health checker service
export NODEMANAGER_MAX_DISK_UTIL_PERCENT=95.0	# Maximum percentage of disk space that may be utilized before a disk is marked as unhealthy
export NODEMANAGER_HEARTBEAT_INTERVAL_MS=5000	# Heartbeat interval in milliseconds for NodeManagers
export TIMELINE_SERVER=false		# Start the YARN Timeline server, also known as Application History server
export TIMELINE_SERVER_D_HEAPSIZE=1024	# YARN Timeline daemon heapsize (MB)
export SCHEDULER_CLASS=fifo		# The class to use as the resource scheduler. Options: fifo, capacity and fair
export SCHEDULER_FAIR_ASSIGN_MULTIPLE=true	# Whether to allow multiple container assignments in one heartbeat
export SCHEDULER_FAIR_DYNAMIC_MAX_ASSIGN=true	# Whether to dynamically determine the amount of resources assigned in one heartbeat
export SCHEDULER_FAIR_MAX_ASSIGN=-1		# Maximum amount of containers that can be assigned in one heartbeat (-1 sets no limit)
export SCHEDULER_FAIR_CONTINUOUS=false		# Enable continuous scheduling. It can cause the ResourceManager to become unresponsive on large clusters
