#!/bin/sh

## Configuration parameters corresponding with the mapred-site.xml file of Hadoop configuration

if [[ $CORES_PER_NODE == 1 ]]
then
	export MAPPERS_PER_NODE=1 	# Maximum number of map tasks per node
	export REDUCERS_PER_NODE=1 	# Maximum number of reduce tasks per node
else
	export MAPPERS_PER_NODE=$(( $CORES_PER_NODE / 2 )) 	# Maximum number of map tasks per node
	export REDUCERS_PER_NODE=$(( $CORES_PER_NODE / 2 )) 	# Maximum number of reduce tasks per node
fi

export MAP_MEMORY_RATIO=1	# Percentage of the container memory allocated per map task
export REDUCE_MEMORY_RATIO=1	# Percentage of the container memory allocated per reduce task
export MAP_MEMORY=`op_int "$CONTAINER_MEMORY * $MAP_MEMORY_RATIO"`	 # The amount of memory to request from YARN per map task (MB)
export REDUCE_MEMORY=`op_int "$CONTAINER_MEMORY	* $REDUCE_MEMORY_RATIO"` # The amount of memory to request from YARN per reduce task (MB)
export MAP_HEAPSIZE_FACTOR=0.90	# Percentage of the mapper memory allocated to heap
export REDUCE_HEAPSIZE_FACTOR=0.90	# Percentage of the reducer memory allocated to heap
export MAP_HEAPSIZE=`op_int "$MAP_MEMORY * $MAP_HEAPSIZE_FACTOR"`		# Heap size per map task (MB)
export REDUCE_HEAPSIZE=`op_int "$REDUCE_MEMORY * $REDUCE_HEAPSIZE_FACTOR"`	# Heap size per reduce task (MB)
export IO_SORT_MB=$(( $MAP_HEAPSIZE / 4 ))	# Total amount of buffer memory to use while sorting files (MB)
export IO_SORT_FACTOR=$(( $IO_SORT_MB / 10 ))	# Number of streams to merge at once while sorting files
export IO_SORT_RECORD_PERCENT=0.05	# The percentage of io.sort.mb dedicated to tracking record boundaries
export IO_SORT_SPILL_PERCENT=0.80	# The soft limit in either the buffer or record collection buffers
export SHUFFLE_PARALLELCOPIES=10 	# Number of parallel transfers run by reduce during the copy (shuffle) phase
export REDUCE_SLOW_START_COMPLETED_MAPS=0.75 # Fraction of the number of maps which should be complete before reduces are scheduled
export MR_JOBHISTORY_SERVER="true"	# Start the MapReduce JobHistoryServer
