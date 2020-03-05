#!/bin/sh

## Configuration parameters corresponding with the yarn-site.xml file of Hadoop configuration

export APP_MASTER_HEAPSIZE=1024	# Application Master heapsize
export APP_MASTER_MEMORY_OVERHEAD=`op_int "$APP_MASTER_HEAPSIZE * 0.1"`	# Overhead of the Application Master memory not allocated to heap
export APP_MASTER_MEMORY_OVERHEAD=$(($APP_MASTER_MEMORY_OVERHEAD>384?$APP_MASTER_MEMORY_OVERHEAD:384))
export APP_MASTER_MEMORY=`op_int "$APP_MASTER_HEAPSIZE + $APP_MASTER_MEMORY_OVERHEAD"` # Application Master memory
export NODEMANAGER_MEMORY_FACTOR=0.95	# Percentage of the node memory available for allocation
export NODEMANAGER_MEMORY=`op_int "$MEMORY_PER_NODE * $NODEMANAGER_MEMORY_FACTOR"`	# Memory available for allocation
export NODEMANAGER_VCORES=$CORES_PER_NODE	# Number of cores per NodeManager
export CONTAINER_MEMORY=`op_int "($NODEMANAGER_MEMORY - $APP_MASTER_MEMORY) / $NODEMANAGER_VCORES"`	# Memory size for containers
export NODEMANAGER_MIN_ALLOCATION=256	# Minimum memory allocation for containers in NodeManager
export NODEMANAGER_INCREMENT_ALLOCATION=128	# Container memory allocations are rounded up to the nearest multiple of this number
export NODEMANAGER_PMEM_CHECK="true"
export NODEMANAGER_VMEM_CHECK="false"
export NODEMANAGER_VMEM_PMEM_RATIO=2.1
export NODEMANAGER_DISK_HEALTH_CHECKER=true     # Enable or disable the disk health checker service
export NODEMANAGER_MAX_DISK_UTIL_PERCENT=95.0	# Maximum percentage of disk space that may be utilized before a disk is marked as unhealthy
