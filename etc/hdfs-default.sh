#!/bin/sh

## Configuration parameters for Hadoop HDFS

export NAMENODE_D_HEAPSIZE=1024		# NameNode daemon heapsize (MB)
export DATANODE_D_HEAPSIZE=1024		# DataNode daemon heapsize (MB)
export BLOCKSIZE=$((128*1024*1024)) 	# HDFS block size (Bytes)
export REPLICATION_FACTOR=3		# Number of block replications
export NAMENODE_HANDLER_COUNT=50	# Number of NameNode RPC server threads: ln(#DataNodes)*20 (eg, 50 threads for 12 DataNodes)
export NAMENODE_ACCESTIME_PRECISION=0	# Last access time (milliseconds) for HDFS files is precise upto this value (0 turns off access times)
export SHORT_CIRCUIT_LOCAL_READS=false	# Enable short-circuit local reads to bypass the DataNode, allowing the client to read the file directly
export DOMAIN_SOCKET_PATH=/var/lib/hdfs/$USER	# Permissions in this special path must be properly configured before enabling the short-circuit reads
export CLIENT_SOCKET_TIMEOUT=60000	# Default timeout value in ms for all sockets
export DATANODE_SOCKET_WRITE_TIMEOUT=60000	# Timeout in ms for clients socket writes to DataNodes
