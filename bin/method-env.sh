#!/bin/sh

export METHOD_NAME=BDEv
export METHOD_VERSION=3.4-dev

if [[ -z $METHOD_HOME ]]
then
        echo "Error: METHOD_HOME must be set"
	exit -1
fi

export METHOD_CONF_DIR=$METHOD_HOME/etc
export METHOD_BIN_DIR=$METHOD_HOME/bin
export METHOD_START_DATE=`date +"%m_%d_%H-%M-%S-%N"`

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
export ILO_SCRIPTS=$THIRD_PARTY_DIR/ilo-4.70.0
export ILO_POWER_SCRIPT_TEMPLATE=$ILO_SCRIPTS/Get_Power_Readings.xml
export ILO_CONFIG_SCRIPT=$ILO_SCRIPTS/locfg.pl

#PLOT
export PLOT_HOME=$METHOD_BIN_DIR/plot

#STAT
export STAT_HOME=$METHOD_BIN_DIR/stat
export STAT_PLOT_HOME=$PLOT_HOME/stat
export DSTAT_HOME=$THIRD_PARTY_DIR/dstat-0.7.3
export DSTAT=$DSTAT_HOME/dstat

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

m_echo "Running $METHOD_NAME version $METHOD_VERSION"

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

#Configuration parameters
ini_conf_params
add_conf_param "method_home" $METHOD_HOME
add_conf_param "method_bin_dir" $METHOD_BIN_DIR
add_conf_param "master_heapsize" $MASTER_HEAPSIZE
add_conf_param "slave_heapsize" $SLAVE_HEAPSIZE
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
add_conf_param "blocksize" $BLOCKSIZE
add_conf_param "replication_factor" $REPLICATION_FACTOR
add_conf_param "namenode_handler_count" $NAMENODE_HANDLER_COUNT
add_conf_param "namenode_accesstime_precision" $NAMENODE_ACCESTIME_PRECISION
add_conf_param "client_shortcircuit_reads" $SHORT_CIRCUIT_LOCAL_READS
add_conf_param "domain_socket_path" "${DOMAIN_SOCKET_PATH}/dn_socket"
add_conf_param "fs_port" $FS_PORT
add_conf_param "io_file_buffer_size" $IO_FILE_BUFFER_SIZE
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
add_conf_param "spark_am_memory" $SPARK_AM_HEAPSIZE
add_conf_param "spark_driver_cores" $SPARK_DRIVER_CORES
add_conf_param "spark_driver_memory" $SPARK_DRIVER_HEAPSIZE
add_conf_param "spark_worker_cores" $SPARK_WORKER_CORES
add_conf_param "spark_worker_memory" $SPARK_WORKER_MEMORY
add_conf_param "spark_workers_per_node" $SPARK_WORKERS_PER_NODE
export SPARK_LOCAL_DIRS=`add_prefix_sufix "$SPARK_LOCAL_DIRS" "" "/spark/local"`
add_conf_param_list "spark_local_dirs" "$SPARK_LOCAL_DIRS" "" ""
add_conf_param "spark_event_log" $SPARK_HISTORY_SERVER
add_conf_param "spark_history_server_dir" $SPARK_HISTORY_SERVER_DIR

#RDMA-SPARK
add_conf_param "rdma_spark_ib_enabled" $RDMA_SPARK_IB_ENABLED
add_conf_param "rdma_spark_roce_enabled" $RDMA_SPARK_ROCE_ENABLED
add_conf_param "rdma_spark_shuffle_chunk_size"	$RDMA_SPARK_SHUFFLE_CHUNK_SIZE

#DataMPI
add_conf_param "datampi_task_heapsize" $DATAMPI_TASK_HEAPSIZE

#FLINK
add_conf_param "flink_taskmanager_slots" $FLINK_TASKMANAGER_SLOTS
export FLINK_TASKMANAGER_TMP_DIRS=`add_prefix_sufix "$FLINK_TASKMANAGER_TMP_DIRS" "" "/flink/local"`
add_conf_param_list "flink_taskmanager_tmp_dirs" "$FLINK_TASKMANAGER_TMP_DIRS" "" ""

