#!/bin/sh

## Configuration parameters corresponding with the hdfs-site.xml file of Hadoop configuration

export BLOCKSIZE=$((128*1024*1024)) 	# HDFS block size (Bytes)
export REPLICATION_FACTOR=3		# Number of block replications
export NAMENODE_HANDLER_COUNT=50	# Number of NameNode RPC server threads: ln(#DataNodes)*20 (eg, 50 threads for 12 DataNodes)
export NAMENODE_ACCESTIME_PRECISION=0	# Last access time (milliseconds) for HDFS files is precise upto this value (0 turns off access times)
export SHORT_CIRCUIT_LOCAL_READS=false	# Enable short-circuit local reads to bypass the DataNode, allowing the client to read the file directly
export DOMAIN_SOCKET_PATH=/var/lib/hdfs/$USER	# Permissions in this special path must be properly configured before enabling the short-circuit reads
