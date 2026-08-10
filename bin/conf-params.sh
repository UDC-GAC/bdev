#!/bin/sh

#Configuration parameters
ini_conf_params
add_conf_param "bdev_home" $BDEV_HOME
add_conf_param "bdev_bin_dir" $BDEV_BIN_DIR
add_conf_param "enable_hostnames" $ENABLE_HOSTNAMES
add_conf_param "hostname_script" $HOSTNAME_SCRIPT
add_conf_param "ssh_opts" "$SSH_OPTS"
add_conf_param "loopback_ip" $LOOPBACK_IP
add_conf_param "tmp_dir" $TMP_DIR
add_conf_param "local_dirs" $LOCAL_DIRS
add_conf_param "load_java_command" "$LOAD_JAVA_COMMAND"
add_conf_param "storage_backend_uri" $STORAGE_BACKEND_URI

#Hadoop
export HDFS_REPLICATION_FACTOR=$REPLICATION_FACTOR
if [ $REPLICATION_FACTOR -gt $SLAVES_NUMBER ]; then
	m_warn "HDFS replication factor changed from $REPLICATION_FACTOR to $SLAVES_NUMBER due to insufficient DataNodes"
	export HDFS_REPLICATION_FACTOR=$SLAVES_NUMBER
fi

if [ "${STORAGE_BACKEND,,}" == "hdfs" ]; then
    export HADOOP_DEFAULT_FS="hdfs://${MASTERNODE}:${HDFS_PORT}"
else
    export HADOOP_DEFAULT_FS="file:///"
fi

add_conf_param "hadoop_default_fs" $HADOOP_DEFAULT_FS
add_conf_param "hdfs_port" $HDFS_PORT
add_conf_param "mappers_per_node" $MAPPERS_PER_NODE
add_conf_param "reducers_per_node" $REDUCERS_PER_NODE
add_conf_param "map_memory_mb" $MAP_MEMORY
add_conf_param "reduce_memory_mb" $REDUCE_MEMORY
add_conf_param "map_heapsize" $MAP_HEAPSIZE
add_conf_param "reduce_heapsize" $REDUCE_HEAPSIZE
add_conf_param "app__heapsize" $APP_MASTER_HEAPSIZE
add_conf_param "app_master_memory_mb" $APP_MASTER_MEMORY
add_conf_param "mr_jobhistory_d_heapsize" $MR_JOBHISTORY_SERVER_D_HEAPSIZE
add_conf_param "blocksize" $BLOCKSIZE
add_conf_param "replication_factor" $HDFS_REPLICATION_FACTOR
add_conf_param "namenode_d_heapsize" $NAMENODE_D_HEAPSIZE
add_conf_param "secondary_namenode_d_heapsize" $SECONDARY_NAMENODE_D_HEAPSIZE
add_conf_param "datanode_d_heapsize" $DATANODE_D_HEAPSIZE
add_conf_param "namenode_handler_count" $NAMENODE_HANDLER_COUNT
NAMENODE_SERVICE_HANDLER_COUNT=$(($NAMENODE_HANDLER_COUNT / 2))
add_conf_param "namenode_service_handler_count" $NAMENODE_SERVICE_HANDLER_COUNT
add_conf_param "datanode_handler_count" $DATANODE_HANDLER_COUNT
add_conf_param "datanode_heartbeat_interval" $DATANODE_HEARTBEAT_INTERVAL
add_conf_param "namenode_accesstime_precision" $NAMENODE_ACCESTIME_PRECISION
add_conf_param "namenode_safemode_time" $NAMENODE_SAFEMODE_TIMEOUT
add_conf_param "client_shortcircuit_reads" $SHORT_CIRCUIT_LOCAL_READS
add_conf_param "domain_socket_path" "${DOMAIN_SOCKET_PATH}/dn_socket"
add_conf_param "client_write_packet_size" $CLIENT_WRITE_PACKET_SIZE
add_conf_param "client_socket_timeout" $CLIENT_SOCKET_TIMEOUT
add_conf_param "client_block_write_retries" $CLIENT_BLOCK_WRITE_RETRIES
CLIENT_BLOCK_LOCATEBLOCK_RETRIES=$(($CLIENT_BLOCK_WRITE_RETRIES * 2))
add_conf_param "client_block_write_locateblock_retries" $CLIENT_BLOCK_LOCATEBLOCK_RETRIES
add_conf_param "datanode_socket_write_timeout" $DATANODE_SOCKET_WRITE_TIMEOUT
add_conf_param "io_file_buffer_size" $IO_FILE_BUFFER_SIZE
add_conf_param "ipc_ping_interval" $IPC_PING_INTERVAL_MS
add_conf_param "ipc_client_rpc_timeout" $IPC_CLIENT_RPC_TIMEOUT_MS
add_conf_param "io_sort_factor" $IO_SORT_FACTOR
add_conf_param "io_sort_mb" $IO_SORT_MB
add_conf_param "shuffle_parallelcopies" $SHUFFLE_PARALLELCOPIES
add_conf_param "io_sort_record_percent" $IO_SORT_RECORD_PERCENT
add_conf_param "io_sort_spill_percent" $IO_SORT_SPILL_PERCENT
add_conf_param "reduce_slow_start_completed_maps" $REDUCE_SLOW_START_COMPLETED_MAPS
add_conf_param_list "dfs_name_dir" "`add_prefix_sufix "$LOCAL_DIRS" "" "/dfs/name"`"
add_conf_param_list "dfs_data_dir" "`add_prefix_sufix "$LOCAL_DIRS" "" "/dfs/data"`"
add_conf_param_list "dfs_checkpoint_dir" "`add_prefix_sufix "$LOCAL_DIRS" "" "/dfs/namesecondary"`"
add_conf_param_list "mapreduce_local_dir" "`add_prefix_sufix "$LOCAL_DIRS" "" "/mapred/local"`"
add_conf_param_list "yarn_local_dirs" "`add_prefix_sufix "$LOCAL_DIRS" "" "/yarn/local"`"
add_conf_param "yarn_timeline_server"	$TIMELINE_SERVER
add_conf_param "yarn_timeline_d_heapsize" $TIMELINE_SERVER_D_HEAPSIZE
add_conf_param "resourcemanager_d_heapsize" $RESOURCEMANAGER_D_HEAPSIZE
add_conf_param "nodemanager_d_heapsize" $NODEMANAGER_D_HEAPSIZE
add_conf_param "nodemanager_min_allocation" $NODEMANAGER_MIN_ALLOCATION
add_conf_param "nodemanager_memory" $NODEMANAGER_MEMORY
add_conf_param "nodemanager_vcores" $NODEMANAGER_VCORES
add_conf_param "nodemanager_increment_allocation" $NODEMANAGER_INCREMENT_ALLOCATION
add_conf_param "nodemanager_pmem_check" $NODEMANAGER_PMEM_CHECK
add_conf_param "nodemanager_vmem_check" $NODEMANAGER_VMEM_CHECK
add_conf_param "nodemanager_vmem_pmem_ratio" $NODEMANAGER_VMEM_PMEM_RATIO
add_conf_param "nodemanager_max_disk_util_percent" $NODEMANAGER_MAX_DISK_UTIL_PERCENT
add_conf_param "nodemanager_disk_health_checker" $NODEMANAGER_DISK_HEALTH_CHECKER
add_conf_param "nodemanager_heartbeat_interval" $NODEMANAGER_HEARTBEAT_INTERVAL_MS
add_conf_param "scheduler_class" $SCHEDULER_CLASS
add_conf_param "scheduler_fair_assignmultiple" $SCHEDULER_FAIR_ASSIGN_MULTIPLE
add_conf_param "scheduler_fair_dynamic_max_assign" $SCHEDULER_FAIR_DYNAMIC_MAX_ASSIGN
add_conf_param "scheduler_fair_max_assign" $SCHEDULER_FAIR_MAX_ASSIGN
add_conf_param "scheduler_fair_continuous_scheduling" $SCHEDULER_FAIR_CONTINUOUS

#RDMA-HADOOP
add_conf_param "rdma_hadoop_ib_enabled" $RDMA_HADOOP_IB_ENABLED
add_conf_param "rdma_hadoop_roce_enabled" $RDMA_HADOOP_ROCE_ENABLED
add_conf_param "rdma_hadoop_dfs_replication_parallel" $RDMA_HADOOP_DFS_REPLICATION_PARALLEL
add_conf_param "rdma_hadoop_dfs_memory_percentage" $RDMA_HADOOP_DFS_MEMORY_PERCENTAGE
add_conf_param "rdma_hadoop_dfs_ssd_used" $RDMA_HADOOP_DFS_SSD_USED
add_conf_param "rdma_hadoop_disk_shuffle_enabled" $RDMA_HADOOP_DISK_SHUFFLE_ENABLED

#SPARK
export SPARK_LOCAL_DIRS=`echo $SPARK_LOCAL_DIRS | tr "," " "`
export SPARK_LOCAL_DIRS=`add_prefix_sufix "$SPARK_LOCAL_DIRS" "" "/spark/local"`

add_conf_param "spark_daemon_memory" $SPARK_DAEMON_MEMORY
add_conf_param "spark_driver_cores" $SPARK_DRIVER_CORES
add_conf_param "spark_driver_memory" $SPARK_DRIVER_HEAPSIZE
add_conf_param "spark_driver_memOverhead" $SPARK_DRIVER_MEMORY_OVERHEAD
add_conf_param "spark_yarn_am_cores" $SPARK_YARN_AM_CORES
add_conf_param "spark_yarn_am_memory" $SPARK_YARN_AM_HEAPSIZE
add_conf_param "spark_yarn_am_memOverhead" $SPARK_YARN_AM_MEMORY_OVERHEAD
add_conf_param "spark_worker_cores" $SPARK_WORKER_CORES
add_conf_param "spark_worker_memory" $SPARK_WORKER_MEMORY
add_conf_param "spark_workers_per_node" $SPARK_WORKERS_PER_NODE
add_conf_param "spark_network_timeout" $SPARK_NETWORK_TIMEOUT
add_conf_param "spark_executor_heartbeat" $SPARK_EXECUTOR_HEARTBEAT_INTERVAL
add_conf_param "spark_shuffle_compress" $SPARK_SHUFFLE_COMPRESS
add_conf_param "spark_shuffle_spill_compress" $SPARK_SHUFFLE_SPILL_COMPRESS
add_conf_param "spark_broadcast_compress" $SPARK_BROADCAST_COMPRESS
add_conf_param "spark_rdd_compress" $SPARK_RDD_COMPRESS
add_conf_param "spark_io_compression_codec" $SPARK_IO_COMPRESSION_CODEC
add_conf_param "spark_serializer" $SPARK_SERIALIZER
add_conf_param "spark_kryo_unsafe" $SPARK_KRYO_UNSAFE
add_conf_param "spark_kryo_buffer_max" $SPARK_KRYO_BUFFER_MAX
add_conf_param "spark_kryo_registrationRequired" $SPARK_KRYO_REGISTRATION_REQUIRED
add_conf_param "spark_memory_fraction" $SPARK_MEMORY_FRACTION
add_conf_param "spark_memory_storage_fraction" $SPARK_MEMORY_STORAGE_FRACTION
add_conf_param_list "spark_local_dirs" "$SPARK_LOCAL_DIRS"
add_conf_param "spark_event_log" $SPARK_HISTORY_SERVER
add_conf_param "spark_history_server_dir" $SPARK_HISTORY_SERVER_DIR
add_conf_param "spark_sql_aqe"  $SPARK_SQL_AQE
add_conf_param "spark_aqe_coalesce_partitions" $SPARK_AQE_COALESCE_PARTITIONS
add_conf_param "spark_aqe_partition_size" $SPARK_AQE_PARTITION_SIZE
add_conf_param "spark_sql_parquet_compression_codec" $SPARK_SQL_PARQUET_COMPRESSION_CODEC

#FLINK
export FLINK_LOCAL_DIRS=`echo $FLINK_LOCAL_DIRS | tr "," " "`
export FLINK_LOCAL_DIRS=`add_prefix_sufix "$FLINK_LOCAL_DIRS" "" "/flink/local"`
export FLINK_TASKMANAGER_MEMORY_NETWORK_MAX=${FLINK_TASKMANAGER_MEMORY_NETWORK_MAX:-"auto"}
export FLINK_TASKMANAGER_MEMORY_NETWORK_FRACTION=${FLINK_TASKMANAGER_MEMORY_NETWORK_FRACTION:-0.1}

if [ "${FLINK_TASKMANAGER_MEMORY_NETWORK_MAX,,}" = "auto" ]; then
	AUTO_FLINK_TASKMANAGER_MEMORY_NETWORK_MAX=$(awk "BEGIN { printf \"%d\", $FLINK_TASKMANAGER_MEMORY * $FLINK_TASKMANAGER_MEMORY_NETWORK_FRACTION }")
	export FLINK_TASKMANAGER_MEMORY_NETWORK_MAX="${AUTO_FLINK_TASKMANAGER_MEMORY_NETWORK_MAX}m"
fi

add_conf_param_list "flink_local_dirs" "$FLINK_LOCAL_DIRS"
add_conf_param "flink_history_server_dir" $FLINK_HISTORY_SERVER_DIR
add_conf_param "flink_taskmanager_slots" $FLINK_TASKMANAGER_SLOTS
add_conf_param "flink_taskmanager_network_netty_timeout" $FLINK_TASKMANAGER_NETWORK_NETTY_TIMEOUT
add_conf_param "flink_taskmanager_memory_network_fraction" $FLINK_TASKMANAGER_MEMORY_NETWORK_FRACTION
add_conf_param "flink_taskmanager_memory_network_max" $FLINK_TASKMANAGER_MEMORY_NETWORK_MAX
add_conf_param "flink_taskmanager_memory_network_min" $FLINK_TASKMANAGER_MEMORY_NETWORK_MIN
add_conf_param "flink_taskmanager_memory_segment_size" $FLINK_TASKMANAGER_MEMORY_SEGMENT_SIZE
add_conf_param "flink_taskmanager_memory_off_heap_shuffle_size" $FLINK_TASKMANAGER_MEMORY_OFF_HEAP_SHUFFLE_SIZE
add_conf_param "flink_taskmanager_memory_off_heap_size" $FLINK_TASKMANAGER_MEMORY_OFF_HEAP_SIZE
add_conf_param "flink_taskmanager_network_sort_shuffle_buffers" $FLINK_TASKMANAGER_NETWORK_SORT_SHUFFLE_BUFFERS
add_conf_param "flink_taskmanager_network_sort_shuffle_parallelism" $FLINK_TASKMANAGER_NETWORK_SORT_SHUFFLE_PARALLELISM
add_conf_param "flink_taskmanager_network_shuffle_compress" $FLINK_TASKMANAGER_NETWORK_SHUFFLE_COMPRESS
add_conf_param "flink_heartbeat_timeout" $FLINK_HEARTBEAT_TIMEOUT
add_conf_param "flink_akka_ask_timeout" $FLINK_AKKA_ASK_TIMEOUT
add_conf_param "flink_akka_tcp_timeout" $FLINK_AKKA_TCP_TIMEOUT
add_conf_param "flink_akka_framesize" $FLINK_AKKA_FRAMESIZE
add_conf_param "flink_rest_client_max_content_length" $FLINK_REST_CLIENT_MAX_CONTENT_LENGTH
