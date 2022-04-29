#!/bin/sh

export METHOD_NAME=BDEv
export METHOD_VERSION=3.8-dev

if [[ -z $METHOD_HOME ]]
then
        echo "Error: METHOD_HOME must be set"
	exit -1
fi

export METHOD_CONF_DIR=$METHOD_HOME/etc
export METHOD_BIN_DIR=$METHOD_HOME/bin
export METHOD_START_DATE=`date +"%d_%m_%Y_%H-%M-%S-%N"`

# Load bash functions
. $METHOD_BIN_DIR/functions.sh

export THIRD_PARTY_DIR=$METHOD_HOME/third-party
export SOLUTIONS_SRC_DIR=$METHOD_HOME/solutions/src

if [ -z "$SOLUTIONS_DIST_DIR" ]
then
	export SOLUTIONS_DIST_DIR=$METHOD_HOME/solutions/dist
fi

export SOLUTIONS_BENCH_DIR=$METHOD_HOME/solutions/benchmarks
export SOLUTIONS_LIB_DIR=$METHOD_HOME/solutions/lib
export COMMON_BENCH_DIR=$SOLUTIONS_BENCH_DIR/common
export COMMON_SRC_DIR=$SOLUTIONS_SRC_DIR/common
export TEMPLATES_DIR=$METHOD_HOME/solutions/templates
export SGE_DAEMONS_DIR=$METHOD_HOME/solutions/daemons/sge
export STD_DAEMONS_DIR=$METHOD_HOME/solutions/daemons/std
export METHOD_EXP_DIR=$METHOD_HOME/experiment
export INIT_SOL_SCRIPT=$METHOD_BIN_DIR/init-sol.sh
export GEN_CONFIG_SCRIPT=$METHOD_BIN_DIR/gen-config.sh
export COPY_DAEMONS_SCRIPT=$METHOD_BIN_DIR/copy-daemons.sh
export CLEAN_DAEMONS_SCRIPT=$METHOD_BIN_DIR/clean-daemons.sh

#ILO
export ILO_HOME=$METHOD_BIN_DIR/ilo
export ILO_SCRIPTS=$THIRD_PARTY_DIR/ilo-5.30.0
export ILO_POWER_SCRIPT_TEMPLATE=$ILO_SCRIPTS/Get_Power_Readings.xml
export ILO_CONFIG_SCRIPT=$ILO_SCRIPTS/locfg.pl

#PLOT
export PLOT_HOME=$METHOD_BIN_DIR/plot

#STAT
export STAT_HOME=$METHOD_BIN_DIR/stat
export STAT_PLOT_HOME=$PLOT_HOME/stat
export DOOL_HOME=$THIRD_PARTY_DIR/dool-1.0.0
export DOOL_COMMAND=$DOOL_HOME/dool
export DOOL_OPTIONS="-T -c -C total --load -ms -d --disk-util -fn --noheaders --noupdate"

#RAPL
export RAPL_HOME=$METHOD_BIN_DIR/rapl
export RAPL_PLOT_HOME=$PLOT_HOME/rapl

#OPROFILE
export OPROFILE_HOME=$METHOD_BIN_DIR/oprofile
export OPROFILE_PLOT_HOME=$PLOT_HOME/oprofile

#BDWatchdog
export BDWATCHDOG_HOME=$METHOD_BIN_DIR/bdwatchdog
export BDWATCHDOG_SRC_DIR=$THIRD_PARTY_DIR/BDWatchdog
export BDWATCHDOG_DAEMONS_DIR=$BDWATCHDOG_SRC_DIR/MetricsFeeder/src/daemons
export BDWATCHDOG_DAEMONS_BIN_DIR=$BDWATCHDOG_SRC_DIR/MetricsFeeder/bin
export BDWATCHDOG_TIMESTAMPING_SERVICE=$BDWATCHDOG_SRC_DIR/TimestampsSnitch/src
export PYTHONPATH=${BDWATCHDOG_SRC_DIR}

# Check if we are under a SGE environment
if [[ -n "$SGE_ROOT" ]]
then
        if [[ -n "$JOB_ID" && -n "$PE_HOSTFILE" ]]
	then
        	export SGE_ENV="true"
	fi
fi

# Check if we are under a SLURM environment
if [[ -n "$SLURM_JOB_ID" ]]
then
        export SLURM_ENV="true"
fi

# Load default configuration
. $METHOD_CONF_DIR/bdev-default.sh
. $METHOD_CONF_DIR/system-default.sh
. $METHOD_CONF_DIR/experiment-default.sh

if [[ -z $EXP_DIR ]]
then
	export EXP_DIR=$METHOD_EXP_DIR
fi

export HOSTFILE_DEFAULT=$EXP_DIR/hostfile

if [[ -z $HOSTFILE ]]
then
	if [[ "$SGE_ENV" == "true" ]]
	then
		HOSTFILE=$PE_HOSTFILE
        elif [[ "$SLURM_ENV" == "true" ]]
        then
                COMPUTE_NODES=`scontrol show hostname $SLURM_JOB_NODELIST`
	else
		HOSTFILE=$HOSTFILE_DEFAULT
	fi
fi

. $EXP_DIR/bdev-conf.sh
. $EXP_DIR/system-conf.sh
. $EXP_DIR/experiment-conf.sh

export CLUSTER_SIZES=`read_list $EXP_DIR/cluster_sizes.lst`
export BENCHMARKS=`read_list $EXP_DIR/benchmarks.lst`
export SOLUTIONS=`read_solutions $EXP_DIR/solutions.lst`

if [[ -z "$LOCAL_DIRS" ]]
then
	export LOCAL_DIRS=${TMP_DIR}
else
	export LOCAL_DIRS="`echo $LOCAL_DIRS | tr "," " "`"
fi

. $METHOD_CONF_DIR/core-default.sh
. $EXP_DIR/core-conf.sh

. $METHOD_CONF_DIR/hdfs-default.sh
. $EXP_DIR/hdfs-conf.sh

. $METHOD_CONF_DIR/yarn-default.sh
. $EXP_DIR/yarn-conf.sh

. $METHOD_CONF_DIR/mapred-default.sh
. $EXP_DIR/mapred-conf.sh

. $METHOD_CONF_DIR/solutions-default.sh
. $EXP_DIR/solutions-conf.sh

export REPORT_DIR=${OUT_DIR}/report_${METHOD_NAME}_${METHOD_START_DATE}
export REPORT_FILE=$REPORT_DIR/summary
export REPORT_LOG=$REPORT_DIR/log
export PLOT_DIR=$REPORT_DIR/graphs
export RAPL_PLOT_DIR=$PLOT_DIR/rapl
export OPROFILE_PLOT_DIR=$PLOT_DIR/oprofile
export ILO_DIR=$PLOT_DIR/ilo
export REPORT_GEN_GRAPHS_FILE=${REPORT_DIR}/gen_all_graphs.sh

if [[ ! -d $REPORT_DIR ]]
then
        mkdir -p $REPORT_DIR
fi

m_echo "Running $METHOD_NAME v$METHOD_VERSION"

# Check modules environment
if [[ "$ENABLE_MODULES" == "true" ]]
then
        if [[ -z $LOAD_JAVA_COMMAND ]]
        then
                export LOAD_JAVA_COMMAND="module load ${MODULE_JAVA}"
        fi
        if [[ -z $LOAD_MPI_COMMAND ]]
        then
                export LOAD_MPI_COMMAND="module load ${MODULE_MPI}"
        fi
else
        if [[ -z $LOAD_JAVA_COMMAND ]]
        then
                JAVA=$(which java 2> /dev/null)
                if [[ "x$JAVA" == "x" ]]
                then
                        m_exit "Missing Java"
                fi
                export JAVA_HOME=$(dirname $(dirname $(readlink -f ${JAVA})))
                export LOAD_JAVA_COMMAND="export JAVA_HOME=$JAVA_HOME"

		export JPS=$(which jps 2> /dev/null)
                if [[ "x$JPS" == "x" ]]
                then
                        m_exit "Missing jps command"
                fi
        fi
        if [[ -z $LOAD_MPI_COMMAND ]]
        then
                MPI=$(which mpirun 2> /dev/null)
                if [[ "x$MPI" == "x" ]]
                then
                        for SOLUTION in $SOLUTIONS
                        do
                                if [[ $SOLUTION == "DataMPI"* ]]
                                then
                                        m_exit "Missing MPI needed for $SOLUTION"
                                fi
                        done
                else
                        MPI_HOME=$(dirname $(dirname $(readlink -f ${MPI})))
                        export LOAD_MPI_COMMAND="export MPI_HOME=$MPI_HOME"
                fi
        fi
fi

# Check expect command
export EXPECT=$(which expect 2> /dev/null)
if [[ "x$EXPECT" == "x" ]]
then
	m_warn "Missing expect command (required when using timeouts)"
fi

# Define variables for BDWatchdog binary daemons
if [[ $ENABLE_BDWATCHDOG == "true" ]]; then
        if [[ $BDWATCHDOG_ATOP == "true" ]]; then
                export ATOP_BIN=$BDWATCHDOG_DAEMONS_BIN_DIR/atop/atop
		if [[ ! -f "$ATOP_BIN" ]] || [[ ! -x "$ATOP_BIN" ]]; then
                        m_exit "atop is enabled but the binary $ATOP_BIN is not found or is not executable"
                fi
        fi
        if [[ $BDWATCHDOG_TURBOSTAT == "true" ]]; then
		export TURBOSTAT_BIN=$TURBOSTAT_BIN_DIR/turbostat
                if [[ ! -f "$TURBOSTAT_BIN" ]] || [[ ! -x "$TURBOSTAT_BIN" ]]; then
                        m_exit "turbostat is enabled but the binary $TURBOSTAT_BIN is not found or is not executable"
                fi
        fi
        if [[ $BDWATCHDOG_NETHOGS == "true" ]]; then
                export NETHOGS_BIN=$BDWATCHDOG_DAEMONS_BIN_DIR/nethogs/nethogs
		if [[ ! -f "$NETHOGS_BIN" ]] || [[ ! -x "$NETHOGS_BIN" ]]; then
                        m_exit "nethogs is enabled but the binary $NETHOGS_BIN is not found or is not executable"
                fi
        fi
fi

if [[ ${ENABLE_HOSTNAMES} == "true" ]]; then
	HOSTNAME_SCRIPT=get_hostname.sh
else
	HOSTNAME_SCRIPT=get_ip_from_hostname.sh
fi

#Configuration parameters
ini_conf_params
add_conf_param "method_home" $METHOD_HOME
add_conf_param "method_bin_dir" $METHOD_BIN_DIR
add_conf_param "hostname_script" $HOSTNAME_SCRIPT
add_conf_param "tmp_dir" $TMP_DIR
add_conf_param "local_dirs" $LOCAL_DIRS
add_conf_param "load_java_command" "$LOAD_JAVA_COMMAND"
add_conf_param "load_mpi_command" "$LOAD_MPI_COMMAND"
add_conf_param "mappers_per_node" $MAPPERS_PER_NODE
add_conf_param "reducers_per_node" $REDUCERS_PER_NODE
add_conf_param "map_memory_mb" $MAP_MEMORY
add_conf_param "reduce_memory_mb" $REDUCE_MEMORY
add_conf_param "map_heapsize" $MAP_HEAPSIZE
add_conf_param "reduce_heapsize" $REDUCE_HEAPSIZE
add_conf_param "app_master_heapsize" $APP_MASTER_HEAPSIZE
add_conf_param "app_master_memory_mb" $APP_MASTER_MEMORY
add_conf_param "jobtracker_d_heapsize" $JOBTRACKER_D_HEAPSIZE
add_conf_param "tasktracker_d_heapsize" $TASKTRACKER_D_HEAPSIZE
add_conf_param "mr_jobhistory_d_heapsize" $MR_JOBHISTORY_SERVER_D_HEAPSIZE
add_conf_param "blocksize" $BLOCKSIZE
add_conf_param "replication_factor" $REPLICATION_FACTOR
add_conf_param "namenode_d_heapsize" $NAMENODE_D_HEAPSIZE
add_conf_param "datanode_d_heapsize" $DATANODE_D_HEAPSIZE
add_conf_param "namenode_handler_count" $NAMENODE_HANDLER_COUNT
NAMENODE_SERVICE_HANDLER_COUNT=$(($NAMENODE_HANDLER_COUNT / 2))
add_conf_param "namenode_service_handler_count" $NAMENODE_SERVICE_HANDLER_COUNT
add_conf_param "datanode_handler_count" $DATANODE_HANDLER_COUNT
add_conf_param "namenode_accesstime_precision" $NAMENODE_ACCESTIME_PRECISION
add_conf_param "client_shortcircuit_reads" $SHORT_CIRCUIT_LOCAL_READS
add_conf_param "domain_socket_path" "${DOMAIN_SOCKET_PATH}/dn_socket"
add_conf_param "client_write_packet_size" $CLIENT_WRITE_PACKET_SIZE
add_conf_param "client_socket_timeout" $CLIENT_SOCKET_TIMEOUT
add_conf_param "client_block_write_retries" $CLIENT_BLOCK_WRITE_RETRIES
CLIENT_BLOCK_LOCATEBLOCK_RETRIES=$(($CLIENT_BLOCK_WRITE_RETRIES * 2))
add_conf_param "client_block_write_locateblock_retries" $CLIENT_BLOCK_LOCATEBLOCK_RETRIES
add_conf_param "datanode_socket_write_timeout" $DATANODE_SOCKET_WRITE_TIMEOUT
add_conf_param "fs_port" $FS_PORT
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

#UDA
add_conf_param "uda_lib_dir" $UDA_LIB_DIR

#RDMA-HADOOP
add_conf_param "rdma_hadoop_ib_enabled" $RDMA_HADOOP_IB_ENABLED
add_conf_param "rdma_hadoop_roce_enabled" $RDMA_HADOOP_ROCE_ENABLED
add_conf_param "rdma_hadoop_dfs_replication_parallel" $RDMA_HADOOP_DFS_REPLICATION_PARALLEL
add_conf_param "rdma_hadoop_dfs_memory_percentage" $RDMA_HADOOP_DFS_MEMORY_PERCENTAGE
add_conf_param "rdma_hadoop_dfs_ssd_used" $RDMA_HADOOP_DFS_SSD_USED
add_conf_param "rdma_hadoop_disk_shuffle_enabled" $RDMA_HADOOP_DISK_SHUFFLE_ENABLED

#SPARK
add_conf_param "spark_daemon_memory" $SPARK_DAEMON_MEMORY
add_conf_param "spark_yarn_am_memory" $SPARK_YARN_AM_HEAPSIZE
add_conf_param "spark_driver_cores" $SPARK_DRIVER_CORES
add_conf_param "spark_driver_memory" $SPARK_DRIVER_HEAPSIZE
add_conf_param "spark_worker_cores" $SPARK_WORKER_CORES
add_conf_param "spark_worker_memory" $SPARK_WORKER_MEMORY
add_conf_param "spark_workers_per_node" $SPARK_WORKERS_PER_NODE
add_conf_param "spark_network_timeout" $SPARK_NETWORK_TIMEOUT
add_conf_param "spark_executor_heartbeat" $SPARK_EXECUTOR_HEARTBEAT_INTERVAL
add_conf_param "spark_shuffle_compress" $SPARK_SHUFFLE_COMPRESS
add_conf_param "spark_shuffle_spill_compress" $SPARK_SHUFFLE_SPILL_COMPRESS
add_conf_param "spark_broadcast_compress" $SPARK_BROADCAST_COMPRESS
add_conf_param "spark_rdd_compress" $SPARK_RDD_COMPRESS
add_conf_param "spark_compression_codec" $SPARK_COMPRESSION_CODEC
add_conf_param "spark_serializer" $SPARK_SERIALIZER
add_conf_param "spark_kryo_unsafe" $SPARK_KRYO_UNSAFE
add_conf_param "spark_kryo_buffer_max" $SPARK_KRYO_BUFFER_MAX
add_conf_param "spark_memory_fraction" $SPARK_MEMORY_FRACTION
add_conf_param "spark_memory_storage_fraction" $SPARK_MEMORY_STORAGE_FRACTION
export SPARK_LOCAL_DIRS=`echo $SPARK_LOCAL_DIRS | tr "," " "`
export SPARK_LOCAL_DIRS=`add_prefix_sufix "$SPARK_LOCAL_DIRS" "" "/spark/local"`
add_conf_param_list "spark_local_dirs" "$SPARK_LOCAL_DIRS"
add_conf_param "spark_event_log" $SPARK_HISTORY_SERVER
add_conf_param "spark_history_server_dir" $SPARK_HISTORY_SERVER_DIR
add_conf_param "spark_sql_aqe"  $SPARK_SQL_AQE
add_conf_param "spark_aqe_coalesce_partitions" $SPARK_AQE_COALESCE_PARTITIONS
add_conf_param "spark_aqe_partition_size" $SPARK_AQE_PARTITION_SIZE

#RDMA-SPARK
add_conf_param "rdma_spark_ib_enabled" $RDMA_SPARK_IB_ENABLED
add_conf_param "rdma_spark_roce_enabled" $RDMA_SPARK_ROCE_ENABLED
add_conf_param "rdma_spark_shuffle_chunk_size"	$RDMA_SPARK_SHUFFLE_CHUNK_SIZE

#DataMPI
add_conf_param "datampi_task_heapsize" $DATAMPI_TASK_HEAPSIZE

#FLINK
add_conf_param "flink_taskmanager_slots" $FLINK_TASKMANAGER_SLOTS
export FLINK_LOCAL_DIRS=`echo $FLINK_LOCAL_DIRS | tr "," " "`
export FLINK_LOCAL_DIRS=`add_prefix_sufix "$FLINK_LOCAL_DIRS" "" "/flink/local"`
add_conf_param_list "flink_local_dirs" "$FLINK_LOCAL_DIRS"
add_conf_param "flink_history_server_dir" $FLINK_HISTORY_SERVER_DIR
add_conf_param "flink_taskmanager_network_netty_timeout" $FLINK_TASKMANAGER_NETWORK_NETTY_TIMEOUT
add_conf_param "flink_taskmanager_memory_network_fraction" $FLINK_TASKMANAGER_MEMORY_NETWORK_FRACTION
add_conf_param "flink_taskmanager_memory_network_max" $FLINK_TASKMANAGER_MEMORY_NETWORK_MAX
add_conf_param "flink_taskmanager_memory_network_min" $FLINK_TASKMANAGER_MEMORY_NETWORK_MIN
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

