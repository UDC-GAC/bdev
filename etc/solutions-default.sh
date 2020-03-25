#!/bin/sh

## Configuration parameters for the frameworks

#FLAME-MR
export FLAMEMR_HADOOP_HOME=${SOLUTIONS_DIST_DIR}/Hadoop-YARN/2.9.2
export FLAMEMR_WORKERS_PER_NODE=1 # Number of workers per node
export FLAMEMR_CORES_PER_WORKER=`op_int "$CORES_PER_NODE / $FLAMEMR_WORKERS_PER_NODE"` # Number of cores per Worker
export FLAMEMR_WORKER_MEMORY_FACTOR=0.90 # Percentage of the Worker memory allocated to heap
export FLAMEMR_WORKER_MEMORY=`op_int "($NODEMANAGER_MEMORY / $FLAMEMR_WORKERS_PER_NODE) * $FLAMEMR_WORKER_MEMORY_FACTOR"` # Worker heapsize
export FLAMEMR_BUFFER_SIZE=1048576 # Memory buffer size
export FLAMEMR_DEBUG_MODE=false # Debug mode 
export FLAMEMR_ITERATIVE_MODE=false # Iterative mode (caches intermediate results)
export FLAMEMR_ITERATIVE_CACHE_INPUT=false # Include input caching in iterative mode
export FLAMEMR_MERGE_OUTPUTS=1 # Number of merge outputs pipelined to the reduce phase
export FLAMEMR_LOAD_BALANCING_MODE=false # Split large reduce partitions to avoid workload unbalance
export FLAMEMR_LOAD_BALANCING_THRESHOLD=0 # Maximum partition size
export FLAMEMR_ADDITIONAL_CONFIGURATION="" # Additional Flame-MR configuration

# RDMA-Hadoop/RDMA-Hadoop-2/RDMA-Hadoop-3
export RDMA_HADOOP_IB_ENABLED=true # Enable RDMA connections through InfiniBand (IB)
export RDMA_HADOOP_ROCE_ENABLED=false # Enable RDMA connections through RDMA over Converged Ethernet (RoCE)
export RDMA_HADOOP_DFS_MEMORY_PERCENTAGE=0.7 # Threshold for RAM Disk usage
export RDMA_HADOOP_DFS_REPLICATION_PARALLEL=false # Enable parallel replication
export RDMA_HADOOP_DFS_SSD_USED=false	# Enable SSD-oriented optimizations for HDFS
export RDMA_HADOOP_DISK_SHUFFLE_ENABLED="true" # Enable disk-based shuffle

# Spark (common)
export SPARK_HADOOP_HOME=${SOLUTIONS_DIST_DIR}/Hadoop-YARN/2.9.2
export SPARK_SCALA_VERSION=2.11	# Scala version used by your Spark distribution
export SPARK_DRIVER_CORES=1 # Number of cores for the driver
export SPARK_DRIVER_MEMORY=`op_int "$CONTAINER_MEMORY * $SPARK_DRIVER_CORES"` # Amount of memory allocated to the driver
export SPARK_DRIVER_HEAPSIZE_FACTOR=0.90 # Percentage of the driver memory allocated to heap
export SPARK_DRIVER_HEAPSIZE=`op_int "$SPARK_DRIVER_MEMORY * $SPARK_DRIVER_HEAPSIZE_FACTOR"` # Driver heapsize
export SPARK_LOCAL_DIRS=$LOCAL_DIRS # Comma-separated list of directories to use for local data
export SPARK_HISTORY_SERVER=false # Start the Spark HistoryServer
export SPARK_HISTORY_SERVER_DIR=/spark/history # HDFS path to store application event logs
export SPARK_NETWORK_TIMEOUT=120 # Spark timeout for network communications (in seconds)
export SPARK_SHUFFLE_COMPRESS=true # Compress map output files
export SPARK_SHUFFLE_SPILL_COMPRESS=true # Compress data spilled during shuffles
export SPARK_BROADCAST_COMPRESS=true # Compress broadcast variables before sending them
export SPARK_RDD_COMPRESS=false # Compress serialized RDD partitions (e.g. for StorageLevel.MEMORY_ONLY_SER)
export SPARK_COMPRESSION_CODEC=lz4 # Codecs: lz4, lzf and snappy. Codec to compress RDD partitions, event log, broadcast variables and shuffle outputs
export SPARK_SERIALIZER=KryoSerializer # Serializers: JavaSerializer and KryoSerializer. Class to use for serializing objects 
export SPARK_KRYO_UNSAFE=true # Whether to use unsafe based Kryo serializer. Can be substantially faster by using Unsafe Based IO

# Spark standalone
export SPARK_DAEMON_MEMORY=1024	# Memory to allocate to the Master, Worker and HistoryServer daemons
export SPARK_MEMORY_RESERVED=`op_int "$SPARK_DAEMON_MEMORY + $DATANODE_D_HEAPSIZE"` # Memory reserved to other services
export SPARK_WORKERS_PER_NODE=1 # Number of workers per node (recommended 1 per node)
export SPARK_WORKER_CORES=`op_int "$NODEMANAGER_VCORES / $SPARK_WORKERS_PER_NODE"` # Number of cores per Worker
export SPARK_WORKER_MEMORY=`op_int "($MEMORY_AVAIL_PER_NODE - $SPARK_MEMORY_RESERVED) / $SPARK_WORKERS_PER_NODE"` # Memory available to Workers
export SPARK_EXECUTORS_PER_WORKER=1 # Number of Executors per Worker (it must be 1 when SPARK_WORKERS_PER_NODE > 1)
export SPARK_CORES_PER_EXECUTOR=`op_int "$SPARK_WORKER_CORES / $SPARK_EXECUTORS_PER_WORKER"` # Number of cores per Executor
export SPARK_EXECUTOR_MEMORY=`op_int "$SPARK_WORKER_MEMORY / $SPARK_EXECUTORS_PER_WORKER"` # Memory allocated to each Executor
export SPARK_EXECUTOR_HEAPSIZE_FACTOR=0.90 # Percentage of the Executor memory allocated to heap
export SPARK_EXECUTOR_HEAPSIZE=`op_int "$SPARK_EXECUTOR_MEMORY * $SPARK_EXECUTOR_HEAPSIZE_FACTOR"` # Executor heapsize

# Spark on YARN (client mode)
export SPARK_YARN_AM_HEAPSIZE=$APP_MASTER_HEAPSIZE # Application Master heapsize
export SPARK_YARN_EXECUTORS_PER_NODE=1 # Number of Executors per node
export SPARK_YARN_CORES_PER_EXECUTOR=`op_int "$NODEMANAGER_VCORES / $SPARK_YARN_EXECUTORS_PER_NODE"` # Number of cores per Executor
export SPARK_YARN_EXECUTOR_MEMORY=`op_int "($NODEMANAGER_MEMORY - $APP_MASTER_MEMORY) / $SPARK_YARN_EXECUTORS_PER_NODE"` # Memory allocated to each Executor
export SPARK_YARN_EXECUTOR_HEAPSIZE_FACTOR=0.90	# Percentage of the Executor memory allocated to heap
export SPARK_YARN_EXECUTOR_HEAPSIZE=`op_int "$SPARK_YARN_EXECUTOR_MEMORY * $SPARK_YARN_EXECUTOR_HEAPSIZE_FACTOR"` # Executor heapsize

# RDMA-Spark
export RDMA_SPARK_IB_ENABLED=true		# Enable RDMA connections through InfiniBand (IB)
export RDMA_SPARK_ROCE_ENABLED=false		# Enable RDMA connections through RDMA over Converged Ethernet (RoCE)
export RDMA_SPARK_SHUFFLE_CHUNK_SIZE=524288	# Chunk size for shuffle

# Flink (common)
export FLINK_HADOOP_HOME=${SOLUTIONS_DIST_DIR}/Hadoop-YARN/2.9.2
export FLINK_SCALA_VERSION=2.11	# Scala version used by your Flink distribution
export FLINK_LOCAL_DIRS=$LOCAL_DIRS # Comma-separated list of directories to use for local data
export FLINK_HISTORY_SERVER=false # Start the Flink HistoryServer
export FLINK_HISTORY_SERVER_DIR=/flink/history # HDFS path to store archives of completed jobs
export FLINK_TASKMANAGERS_PER_NODE=1 # Number of TaskManagers per node
export FLINK_TASKMANAGER_SLOTS=`op_int "$NODEMANAGER_VCORES / $FLINK_TASKMANAGERS_PER_NODE"` # Number of slots per TaskManager
export FLINK_TASKMANAGER_PREALLOCATE_MEMORY=false # TaskManager preallocate memory
export FLINK_NETWORK_TIMEOUT=120 # Flink timeout for network communications (in seconds)

# Flink standalone
export FLINK_JOBMANAGER_HEAPSIZE=1024	# JobManager heapsize
export FLINK_MEMORY_RESERVED=`op_int "$FLINK_JOBMANAGER_HEAPSIZE + $DATANODE_D_HEAPSIZE"` # Memory reserved to other services
export FLINK_TASKMANAGER_MEMORY=`op_int "($MEMORY_AVAIL_PER_NODE - $FLINK_MEMORY_RESERVED) / $FLINK_TASKMANAGERS_PER_NODE"` # Memory allocated to each TaskManager
export FLINK_TASKMANAGER_HEAPSIZE_FACTOR=0.90 # Percentage of the TaskManager memory allocated to heap
export FLINK_TASKMANAGER_HEAPSIZE=`op_int "$FLINK_TASKMANAGER_MEMORY * $FLINK_TASKMANAGER_HEAPSIZE_FACTOR"` # TaskManager heapsize

# Flink on YARN
export FLINK_YARN_JOBMANAGER_HEAPSIZE=$APP_MASTER_HEAPSIZE # JobManager heapsize
export FLINK_YARN_TASKMANAGER_MEMORY=`op_int "($NODEMANAGER_MEMORY - $APP_MASTER_MEMORY) / $FLINK_TASKMANAGERS_PER_NODE"` # Memory allocated to each TaskManager
export FLINK_YARN_TASKMANAGER_HEAPSIZE_FACTOR=0.90 # Percentage of the TaskManager memory allocated to heap
export FLINK_YARN_TASKMANAGER_HEAPSIZE=`op_int "$FLINK_YARN_TASKMANAGER_MEMORY * $FLINK_YARN_TASKMANAGER_HEAPSIZE_FACTOR"` # TaskManager heapsize

# DataMPI
export DATAMPI_HADOOP_HOME=${SOLUTIONS_DIST_DIR}/Hadoop/1.2.1
export DATAMPI_TASK_HEAPSIZE_FACTOR=0.90 # Percentage of the task memory allocated to heap
export DATAMPI_TASK_HEAPSIZE=`op_int "$NODEMANAGER_MEMORY * $DATAMPI_TASK_HEAPSIZE_FACTOR"` # Task heapsize

# Mellanox UDA library
export UDA_VERSION=3.4.1 # UDA library version
export UDA_LIB_DIR=$SOLUTIONS_LIB_DIR/uda-$UDA_VERSION # UDA library directory

# Apache Mahout
export MAHOUT_HEAPSIZE=1024		# Heap size for Mahout master process
export HADOOP_1_MAHOUT_VERSION=0.11.2	# Mahout version for Hadoop 1
export HADOOP_2_MAHOUT_VERSION=0.11.2	# Mahout version for Hadoop 2 (YARN)

# Apache Hive
export HADOOP_1_HIVE_VERSION=1.2.1	# Hive version for Hadoop 1
export HADOOP_2_HIVE_VERSION=1.2.1	# Hive version for Hadoop 2 (YARN)
export HIVE_TMP_DIR=/hive/tmp		# HDFS directory to store temporary files
