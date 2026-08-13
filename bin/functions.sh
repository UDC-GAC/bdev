#!/bin/bash

function get_date {
	DATE=`date '+%d/%m/%Y %H:%M:%S'`
}

export -f get_date

function m_echo() {
	get_date
	echo -e "\e[48;5;2m[${APP_NAME} $DATE INFO]\e[0m $@" 
	echo "$DATE > $@" >> $REPORT_LOG
}

export -f m_echo

function m_err() {
	get_date
	echo -e "\e[48;5;1m[${APP_NAME} $DATE ERR ]\e[0m $@" >&2
	echo "$DATE ! $@" >> $REPORT_LOG
}

export -f m_err

function m_warn() {
	get_date
	echo -e "\e[48;5;208m[${APP_NAME} $DATE WARN]\e[0m $@"
	echo "$DATE ! $@" >> $REPORT_LOG
}

export -f m_warn

function m_exit() {
	m_err $@
	bash $YARN_KILLALL_SCRIPT
	bash $CLEAN_DAEMONS_SCRIPT
	exit -1
}

export -f m_exit

function m_start_message()
{
	m_echo "Frameworks directory: $FRAMEWORKS_DIR"
	m_echo "Frameworks ($NUM_SOLUTIONS): $SOLUTIONS"
	m_echo "Benchmarks ($NUM_BENCHMARKS): $BENCHMARKS"
	m_echo "Benchmark executions: $NUM_EXECUTIONS"
	m_echo "Cluster sizes ($NUM_CLUSTERS): $CLUSTER_SIZES"
	m_echo "Storage backend: $STORAGE_BACKEND"
	if [ "${STORAGE_BACKEND,,}" == "nfs" ]; then
		m_echo "NFS mount point: $NFS_MOUNT_POINT"
	fi
	m_echo "JVM: $LOAD_JAVA_COMMAND"
}

export -f m_start_message

function m_stop_message()
{
	m_echo "$APP_NAME v$APP_VERSION finished"
	m_echo "Report summary stored at $REPORT_FILE"
}

export -f m_stop_message

function op(){
	echo "scale=4; ($*)/1 " | bc
}

export -f op

function op_int(){
	echo "scale=0; ($*)/1 " | bc
}

export -f op_int

function read_list() {

	values=""
	while read line || [[ -n "$line" ]]
	do
		val=`echo "$line" | sed -r -e 's/#.*$//g'`
		values="$values $val"
	done < $1 

	echo $values
}

export -f read_list

function read_solutions() {

	values=""
	while read line || [[ -n "$line" ]]
	do
		sol=`echo "$line" | sed -r -e 's/#.*$//g' | awk '{print $1}'`
		if [ -n "$sol" ]
		then
			version=`echo "$line" | sed -r -e 's/#.*$//g' | awk '{print $2}'`
			net_if=`echo "$line" | sed -r -e 's/#.*$//g' | awk '{print $3}'`
			values="$values ${sol}_${version}_${net_if}"
		fi
	done < $1 

	echo $values
}

export -f read_solutions

function get_num_conf_params() {
    echo "${#CONFIG_KEYS[@]}"
}

export -f get_num_conf_params

function ini_conf_params() {
    CONFIG_KEYS=()
    CONFIG_VALUES=()
}

export -f ini_conf_params

function add_conf_param() {
    local key=$1
    local value=$2

    local i
    for i in "${!CONFIG_KEYS[@]}"; do
        if [[ ${CONFIG_KEYS[i]} == "$key" ]]; then
            CONFIG_VALUES[i]=$value
            return
        fi
    done

    CONFIG_KEYS+=("$key")
    CONFIG_VALUES+=("$value")
}

export -f add_conf_param

function remove_conf_param() {
    local param="$1"
    local new_keys=()
    local new_values=()

    for ((i=0; i<${#CONFIG_KEYS[@]}; i++)); do
        if [[ "${CONFIG_KEYS[$i]}" != "$param" ]]; then
            new_keys+=("${CONFIG_KEYS[$i]}")
            new_values+=("${CONFIG_VALUES[$i]}")
        fi
    done

    CONFIG_KEYS=("${new_keys[@]}")
    CONFIG_VALUES=("${new_values[@]}")
}

export -f remove_conf_param

function exist_conf_param() {
    local param="$1"

    for key in "${CONFIG_KEYS[@]}"; do
        if [[ "$key" == "$param" ]]; then
            return 1
        fi
    done

    return 0
}

export -f exist_conf_param

function add_conf_param_list() {
    local key="$1"
    local param_list="$2"
    local value=""
    local first=true

    for param in $param_list; do
        if $first; then
            value="$param"
            first=false
        else
            value+=",${param}"
        fi
    done

    add_conf_param "$key" "$value"
}

export -f add_conf_param_list

function add_prefix_sufix() {
    local param_list="$1"
    local prefix="$2"
    local sufix="$3"
    local result=""

    for param in $param_list; do
        result+=" ${prefix}${param}${sufix}"
    done

    echo "${result# }"
}

export -f add_prefix_sufix

function get_conf_key() {
    local index=$(( $1 - 1 ))

    if (( index >= 0 && index < ${#CONFIG_KEYS[@]} )); then
        echo "${CONFIG_KEYS[$index]}"
    fi
}

export -f get_conf_key

function get_conf_value() {
    local index=$(( $1 - 1 ))

    if (( index >= 0 && index < ${#CONFIG_VALUES[@]} )); then
        echo "${CONFIG_VALUES[$index]}"
    fi
}

export -f get_conf_value

function load_nodes() 
{
	export MASTERNODE=`echo $@ | cut -d " " -f 1`
	MAX_NODES=1
	SLAVENODES=""
	for HOST in `echo $@ | cut -d " " -f 2-`
	do
		SLAVENODES="$SLAVENODES $HOST"
		MAX_NODES=$(( $MAX_NODES + 1 ))
	done
	export SLAVENODES
	export MAX_NODES
	export CLUSTER_SIZES=`echo $CLUSTER_SIZES | sed -e "s/MAX/$MAX_NODES/gI"`
}

export -f load_nodes

function get_nodes_by_hostname() 
{
	NODE_FILE=${1}
        NODES=${*:2}
	OUT_NODES=""
	touch $NODE_FILE
        for NODE in $NODES
        do
        	if [[ $NODE == "localhost" ]] || [[ $NODE == $LOOPBACK_IP ]]; then
        		OUT=`echo $LOOPBACK_IP localhost`
        	else
			OUT=`$RESOLVEIP_COMMAND hosts $NODE`
		fi
		
		if [[ -z "${OUT}" ]]; then
			m_err "Node $NODE could not be revolved"
			OUT_NODES=""
			return 1
		fi
		NODE_IP=`echo $OUT | awk '{print $1}'`
		NODE_NAME=`echo $OUT | awk '{print $2}'`

		if [[ ${ENABLE_HOSTNAMES} == "true" ]]; then
			OUT_NODES="${OUT_NODES} ${NODE_NAME}"
		else
			OUT_NODES="${OUT_NODES} ${NODE_IP}"
		fi

                echo "$NODE_NAME $NODE_IP" >> $NODE_FILE
        done

        echo $OUT_NODES
}

export -f get_nodes_by_hostname

function get_nodes_by_interface() 
{
	NODE_FILE=${1}
	INTERFACE=${2}
	NODES=${*:3}
	OUT_NODES=""
	touch $NODE_FILE
        SUCCESS=1
        for NODE in $NODES
        do
                INTERFACE_DATA=`$SSH_CMD $NODE "$IP_COMMAND a s $INTERFACE" | grep inet`
                if [[ ! $? -eq 0 ]]; then
                        m_err "$INTERFACE interface not found or not configured for $NODE"
			OUT_NODES=""
			return 1
                fi
                INTERFACE_IP=`echo $INTERFACE_DATA | awk '{print $2}' | cut -d '/' -f 1 | head -n 1`
                if [[ -z "${INTERFACE_IP}" ]]; then
                        m_err "IP not found for $NODE using $INTERFACE interface"
			OUT_NODES=""
			return 1
                fi
                OUT=`$RESOLVEIP_COMMAND hosts $INTERFACE_IP`
                if [[ -z "${OUT}" ]]; then
                        SUCCESS=0
                        NODE_IP=$INTERFACE_IP
                        NODE_NAME=$NODE
                else
                        NODE_IP=`echo $OUT | awk '{print $1}'`
                        NODE_NAME=`echo $OUT | awk '{print $2}'`
                fi

                if [[ ${ENABLE_HOSTNAMES} == "true" ]]; then
                        OUT_NODES="${OUT_NODES} ${NODE_NAME}"
                else
                        OUT_NODES="${OUT_NODES} ${NODE_IP}"
                fi

                echo "$NODE_NAME $NODE_IP" >> $NODE_FILE
        done

        echo $OUT_NODES

        if [[ $SUCCESS -ne 1 ]]; then
                m_warn "IP to hostname resolution failed for $INTERFACE"
        fi
}

export -f get_nodes_by_interface

function set_network_configuration()
{
	if [[ "${SOLUTION}" == "NONE" ]]; then
		load_nodes ${COMPUTE_NODES}
		export NET_INTERFACE=default
		FILE=$NODE_FILE
	elif [[ "${SOLUTION_NET_INTERFACE}" == "eth" ]]; then
		if [[ -n ${ETH_COMPUTE_NODES} ]]; then
			load_nodes ${ETH_COMPUTE_NODES}
			export NET_INTERFACE=$ETH_INTERFACE
			FILE=$NODE_FILE_ETH
		else
			load_nodes ${COMPUTE_NODES}
			export NET_INTERFACE=default
			FILE=$NODE_FILE
		fi
	elif [[ "${SOLUTION_NET_INTERFACE}" == "ipoib" ]]; then
		if [[ -n ${IPOIB_COMPUTE_NODES} ]]; then
			load_nodes ${IPOIB_COMPUTE_NODES}
			export NET_INTERFACE=$IPOIB_INTERFACE
			FILE=$NODE_FILE_IPOIB
		else
			load_nodes ${COMPUTE_NODES}
			export NET_INTERFACE=default
			FILE=$NODE_FILE
		fi
	else
		m_exit "Invalid network interface $SOLUTION_NET_INTERFACE for $SOLUTION. Revise network settings"
	fi

	m_echo "Using $NET_INTERFACE interface and hostfile: $FILE"
	MASTERIP=`$BDEV_BIN_DIR/get_ip_from_hostname.sh $FILE`
	add_conf_param "master" $MASTERNODE
	add_conf_param "ip_master" $MASTERIP
	add_conf_param "net_interface" $NET_INTERFACE
	add_conf_param "hostfile" $FILE
}

export -f set_network_configuration

function set_directory_configuration()
{
	if [[ -z "${SOL_CONF_DIR:-}" ]]; then
		m_exit "SOL_CONF_DIR is not defined or is empty"
	fi
	
	mkdir -p $SOL_CONF_DIR
	cp -r $SOL_CONF_DIR_SRC/* $SOL_CONF_DIR
	chmod -R +w $SOL_CONF_DIR
	if [[ ! -d "$SOL_CONF_DIR" ]]; then
		m_exit "SOL_CONF_DIR does not exist or is not a directory: $SOL_CONF_DIR"
	fi
	add_conf_param "sol_conf_dir" $SOL_CONF_DIR
	add_conf_param "sol_log_dir" $SOL_LOG_DIR
	add_conf_param "hadoop_conf_dir" $HADOOP_CONF_DIR
	add_conf_param "hadoop_home" $HADOOP_HOME
}

export -f set_directory_configuration

function timestamp(){
    nanosec=`date +%s%N`
    echo `expr $nanosec / 1000000`
}

export -f timestamp

function set_cluster_size()
{
	export CLUSTER_SIZE
	export SLAVES_NUMBER=$((CLUSTER_SIZE - 1))
	export CLUSTER_SIZE_REPORT_DIR=$REPORT_DIR/${CLUSTER_SIZE}
	m_echo "Cluster size set to $CLUSTER_SIZE"
}

export -f set_cluster_size

function set_solution()
{
	export SOLUTION
	export SOLUTION_NAME=`echo $SOLUTION | cut -d '_' -f 1`
	export SOLUTION_VERSION=`echo $SOLUTION | cut -d '_' -f 2`
	export SOLUTION_NET_INTERFACE=`echo $SOLUTION | cut -d '_' -f 3 | awk '{print tolower($0)}'`
	export SOLUTION_DIR=${SOLUTIONS_SRC_DIR}/${SOLUTION_NAME}
	SOLUTION_NUM=$1

	if [[ "$SOLUTION_NAME" == "Spark-YARN" ]]
	then
		SOLUTION_NAME="Spark"
	elif [[ "$SOLUTION_NAME" == "Flink-YARN" ]]
	then
		SOLUTION_NAME="Flink"
	fi

	export SOLUTION_HOME=${FRAMEWORKS_DIR}/${SOLUTION_NAME}/${SOLUTION_VERSION}
	export SOLUTION_REPORT_DIR=${CLUSTER_SIZE_REPORT_DIR}/${SOLUTION}

	if [[ ! -d $SOLUTION_HOME ]]
	then
		m_exit "Framework $SOLUTION not found at $SOLUTION_HOME"
	else
		m_echo "Framework set to $SOLUTION: $SOLUTION_HOME"
	fi

	if [[ "$SOLUTION_NAME" == "Spark" ]]
        then
                if [[ ! -d $SPARK_HADOOP_HOME ]]
                then
                        m_exit "Hadoop distribution not found at $SPARK_HADOOP_HOME"
                fi
		HADOOP_VERSION=`echo ${SPARK_HADOOP_HOME##*/}`
	elif [[ "$SOLUTION_NAME" == "Flink" ]]
        then
                if [[ ! -d $FLINK_HADOOP_HOME ]]
                then
                        m_exit "Hadoop distribution not found at $FLINK_HADOOP_HOME"
                fi
		HADOOP_VERSION=`echo ${FLINK_HADOOP_HOME##*/}`
	else
		HADOOP_VERSION=`echo ${SOLUTION_HOME##*/}`
	fi

	if [[ $NUM_SOLUTIONS -gt 1 ]]; then
		if [[ $SOLUTION_NUM -gt 1 ]]; then
			export LAST_HADOOP_VERSION=$CURRENT_HADOOP_VERSION
		else
			export LAST_HADOOP_VERSION="null"
		fi
	fi

	export CURRENT_HADOOP_VERSION=`echo ${HADOOP_VERSION##*/}`
	mkdir -p $SOLUTION_REPORT_DIR
	unset FINISH
}

export -f set_solution

function set_nosolution()
{
	export SOLUTION_HOME=""
        export SOLUTION_REPORT_DIR=${CLUSTER_SIZE_REPORT_DIR}/${SOLUTION}
	mkdir -p $SOLUTION_REPORT_DIR
	unset FINISH
}

export -f set_nosolution

function start_solution(){

	if [[ -n "$FRAMEWORK_SETUP" ]]
	then
		m_echo "Setting up $SOLUTION: $FRAMEWORK_SETUP"
	
		bash -c "$FRAMEWORK_SETUP"
	fi
}

export -f start_solution

function end_solution(){

	if [[ -n "$FRAMEWORK_CLEANUP" ]]
	then
		m_echo "Cleaning up $SOLUTION: $FRAMEWORK_CLEANUP"
	
		bash -c "$FRAMEWORK_CLEANUP"
	fi
}

export -f end_solution

function write_report(){
	printf " %-5s \t %-25s \t %-20s \t %-10s" $CLUSTER_SIZE $SOLUTION $BENCHMARK $ELAPSED_TIMES >> $REPORT_FILE
	printf "\n" >> $REPORT_FILE

	if [[ $ENABLE_PLOT == "true" ]]
	then
		m_echo "Generating performance graphs"
		if [[ ! -f "$PLOT_DIR" ]]
		then
			mkdir -p $PLOT_DIR
		fi
		bash $PLOT_HOME/plot_benchmarks.sh >> $PLOT_DIR/log 2>&1
	fi

	if [[ $ENABLE_RAPL == "true" ]]
	then
		m_echo "Generating rapl graphs"
		if [[ ! -f "$RAPL_PLOT_DIR" ]]
		then
			mkdir -p $RAPL_PLOT_DIR
		fi
		bash $RAPL_PLOT_HOME/plot_benchmarks.sh >> $RAPL_PLOT_DIR/log 2>&1
	fi

	if [[ $ENABLE_OPROFILE == "true" ]]
	then
		m_echo "Generating oprofile graphs"
		if [[ ! -f "$OPROFILE_PLOT_DIR" ]]
		then
			mkdir -p $OPROFILE_PLOT_DIR
		fi
		bash $OPROFILE_PLOT_HOME/plot_benchmarks.sh >> $OPROFILE_PLOT_DIR/log 2>&1
	fi
}

export -f write_report

function begin_report(){
	REPORT="$APP_NAME v$APP_VERSION report \n"
	REPORT="$REPORT \n Report directory: \n"
	REPORT="$REPORT \t $REPORT_DIR \n"
	REPORT="$REPORT \n Configuration: \n"
	REPORT="$REPORT \t Frameworks directory  \t\t\t $FRAMEWORKS_DIR \n"
	REPORT="$REPORT \t Frameworks  \t\t\t\t $SOLUTIONS \n"
	REPORT="$REPORT \t Storage backend  \t\t\t $STORAGE_BACKEND \n"
	if [ "${STORAGE_BACKEND,,}" == "nfs" ]; then
		REPORT="$REPORT \t NFS mount point  \t\t\t $NFS_MOUNT_POINT \n"
	fi
	REPORT="$REPORT \t Storage backend URI  \t\t\t $STORAGE_BACKEND_URI \n"
	REPORT="$REPORT \t Cluster nodes  \t\t\t $MASTERNODE $SLAVENODES \n"
	REPORT="$REPORT \t Cluster sizes  \t\t\t $CLUSTER_SIZES \n"
	REPORT="$REPORT \t Benchmarks  \t\t\t\t $BENCHMARKS \n"
	REPORT="$REPORT \t Benchmark executions  \t\t\t $NUM_EXECUTIONS \n"
	REPORT="$REPORT \t TestDFSIO num of files \t\t $DFSIO_N_FILES \n"
	REPORT="$REPORT \t TestDFSIO file size (MB) \t\t $DFSIO_FILE_SIZE \n"
	REPORT="$REPORT \t WordCount datasize (B) \t\t $WORDCOUNT_DATASIZE \n"
	REPORT="$REPORT \t Sort datasize (B) \t\t\t $SORT_DATASIZE \n"
	REPORT="$REPORT \t TeraSort datasize (B) \t\t\t $TERASORT_DATASIZE \n"
	REPORT="$REPORT \t Grep datasize (B) \t\t\t $GREP_DATASIZE \n"
	REPORT="$REPORT \t TPCx-HS datasize (B) \t\t\t $TPCX_HS_DATASIZE \n"
	REPORT="$REPORT \t PageRank pages \t\t\t $PAGERANK_PAGES \n"
	REPORT="$REPORT \t PageRank iterations \t\t\t $PAGERANK_MAX_ITERATIONS \n"
	REPORT="$REPORT \t ConCmpt pages \t\t\t\t $CC_PAGES \n"
	REPORT="$REPORT \t ConCmpt iterations \t\t\t $CC_MAX_ITERATIONS \n"
	REPORT="$REPORT \t KMeans num of clusters \t\t $KMEANS_NUM_OF_CLUSTERS \n"
	REPORT="$REPORT \t KMeans dimensions \t\t\t $KMEANS_DIMENSIONS \n"
	REPORT="$REPORT \t KMeans num of samples \t\t\t $KMEANS_NUM_OF_SAMPLES \n"
	REPORT="$REPORT \t KMeans samples per file \t\t $KMEANS_SAMPLES_PER_INPUTFILE \n"
	REPORT="$REPORT \t KMeans convergence delta \t\t $KMEANS_CONVERGENCE_DELTA \n"
	REPORT="$REPORT \t KMeans iterations \t\t\t $KMEANS_MAX_ITERATIONS \n"
	REPORT="$REPORT \t Bayes pages \t\t\t\t $BAYES_PAGES \n"
	REPORT="$REPORT \t Bayes clasess \t\t\t\t $BAYES_CLASSES \n"
	REPORT="$REPORT \t Bayes ngrams \t\t\t\t $BAYES_NGRAMS \n"
	REPORT="$REPORT \t Aggregations pages \t\t\t $AGGREGATION_PAGES \n"
	REPORT="$REPORT \t Aggregations uservisits \t\t $AGGREGATION_USERVISITS \n"
	REPORT="$REPORT \t Join pages \t\t\t\t $JOIN_PAGES \n"
	REPORT="$REPORT \t Join uservisits \t\t\t $JOIN_USERVISITS \n"
	REPORT="$REPORT \t Scan pages \t\t\t\t $SCAN_PAGES \n"
	REPORT="$REPORT \t Scan uservisits \t\t\t $SCAN_USERVISITS \n"
	REPORT="$REPORT \t Mahout heapsize (MB)   \t\t $MAHOUT_HEAPSIZE \n"
	REPORT="$REPORT \t Tmp dir  \t\t\t\t $TMP_DIR \n"
	REPORT="$REPORT \t Local dirs  \t\t\t\t $LOCAL_DIRS \n"
	REPORT="$REPORT \t SSH \t\t\t\t\t $SSH_CMD \n"
	REPORT="$REPORT \t JVM \t\t\t\t\t $LOAD_JAVA_COMMAND \n"
	REPORT="$REPORT \t JAVA_HOME \t\t\t\t $JAVA_HOME \n"
	if [[ -n $ETH_INTERFACE ]]
	then
		REPORT="$REPORT \t ETH interface  \t\t\t $ETH_INTERFACE \n"
	else
		REPORT="$REPORT \t ETH interface  \t\t\t Not specified \n"
	fi
	if [[ -n $IPOIB_INTERFACE ]]
	then
		REPORT="$REPORT \t IPoIB interface  \t\t\t $IPOIB_INTERFACE \n"
	else
		REPORT="$REPORT \t IPoIB interface  \t\t\t Not specified \n"
	fi
	REPORT="$REPORT \t Cores per node \t\t\t $CORES_PER_NODE \n"
	REPORT="$REPORT \t Total memory per node (MB) \t\t $MEMORY_PER_NODE \n"
	REPORT="$REPORT \t Allocated memory per node (MB) \t $MEMORY_ALLOC_PER_NODE \n"
	REPORT="$REPORT \t YARN RM daemon heapsize (MB)  \t\t $RESOURCEMANAGER_D_HEAPSIZE \n"
	REPORT="$REPORT \t YARN NM daemon heapsize (MB)  \t\t $NODEMANAGER_D_HEAPSIZE \n"
	REPORT="$REPORT \t YARN NM vcores  \t\t\t $NODEMANAGER_VCORES \n"
	REPORT="$REPORT \t YARN NM memory (MB)  \t\t\t $NODEMANAGER_MEMORY \n"
	REPORT="$REPORT \t YARN AM memory (MB)  \t\t\t $APP_MASTER_MEMORY \n"
	REPORT="$REPORT \t YARN AM heapsize (MB) \t\t\t $APP_MASTER_HEAPSIZE \n"
	REPORT="$REPORT \t YARN AM overhead (MB) \t\t\t $APP_MASTER_MEMORY_OVERHEAD \n"
	REPORT="$REPORT \t YARN container memory (MB) \t\t $CONTAINER_MEMORY \n"
	REPORT="$REPORT \t HDFS NN daemon heapsize (MB)  \t\t $NAMENODE_D_HEAPSIZE \n"
	REPORT="$REPORT \t HDFS DN daemon heapsize (MB)  \t\t $DATANODE_D_HEAPSIZE \n"
	REPORT="$REPORT \t HDFS SN daemon heapsize (MB)  \t\t $SECONDARY_NAMENODE_D_HEAPSIZE \n"
	REPORT="$REPORT \t HDFS block size (B)  \t\t\t $HDFS_BLOCKSIZE \n"
	REPORT="$REPORT \t HDFS replication factor  \t\t $HDFS_REPLICATION_FACTOR \n"
	REPORT="$REPORT \t HDFS format  \t\t\t\t $FORMAT_HDFS \n"
	REPORT="$REPORT \t HDFS delete data \t\t\t $DELETE_HDFS \n"
	REPORT="$REPORT \t HDFS NN handlers \t\t\t $NAMENODE_HANDLER_COUNT \n"
	REPORT="$REPORT \t HDFS NN access times \t\t\t $NAMENODE_ACCESTIME_PRECISION \n"
	REPORT="$REPORT \t HDFS NN safe mode extension \t\t $NAMENODE_SAFEMODE_TIMEOUT \n"
	REPORT="$REPORT \t HDFS DN handlers \t\t\t $DATANODE_HANDLER_COUNT \n"
	REPORT="$REPORT \t HDFS DN heartbeat interval \t\t $DATANODE_HEARTBEAT_INTERVAL \n"
	REPORT="$REPORT \t HDFS short-circuit local reads \t $SHORT_CIRCUIT_LOCAL_READS \n"
	REPORT="$REPORT \t HDFS client domain socket path \t $DOMAIN_SOCKET_PATH \n"
	REPORT="$REPORT \t Mappers per node  \t\t\t $MAPPERS_PER_NODE \n"
	REPORT="$REPORT \t Reducers per node  \t\t\t $REDUCERS_PER_NODE \n"
	REPORT="$REPORT \t Mapper memory (MB)   \t\t\t $MAP_MEMORY \n"
	REPORT="$REPORT \t Reducer memory (MB)   \t\t\t $REDUCE_MEMORY \n"
	REPORT="$REPORT \t Mapper heapsize (MB)   \t\t $MAP_HEAPSIZE \n"
	REPORT="$REPORT \t Reducer heapsize (MB)   \t\t $REDUCE_HEAPSIZE \n"
	REPORT="$REPORT \t MapReduce io.file.buffer.size (B)  \t $IO_FILE_BUFFER_SIZE \n"
	REPORT="$REPORT \t MapReduce io.sort.mb (MB)  \t\t $IO_SORT_MB \n"
	REPORT="$REPORT \t MapReduce io.sort.factor  \t\t $IO_SORT_FACTOR \n"
	REPORT="$REPORT \t MapReduce io.sort.spill.percent  \t $IO_SORT_SPILL_PERCENT \n"
	REPORT="$REPORT \t MapReduce shuffle.parallelcopies \t $SHUFFLE_PARALLELCOPIES \n"
	REPORT="$REPORT \t MapReduce reduce.start.completedmaps \t $REDUCE_SLOW_START_COMPLETED_MAPS \n"
	REPORT="$REPORT \t Spark API  \t\t\t\t $SPARK_API \n"
	REPORT="$REPORT \t Spark driver cores   \t\t\t $SPARK_DRIVER_CORES \n"
	REPORT="$REPORT \t Spark driver memory (MB)   \t\t $SPARK_DRIVER_MEMORY \n"
	REPORT="$REPORT \t Spark driver heapsize (MB)   \t\t $SPARK_DRIVER_HEAPSIZE \n"
	REPORT="$REPORT \t Spark driver overhead (MB)   \t\t $SPARK_DRIVER_MEMORY_OVERHEAD \n"
	REPORT="$REPORT \t Spark daemon memory (MB)  \t\t $SPARK_DAEMON_MEMORY \n"
	REPORT="$REPORT \t Spark workers per node   \t\t $SPARK_WORKERS_PER_NODE \n"
	REPORT="$REPORT \t Spark worker cores   \t\t\t $SPARK_WORKER_CORES \n"
	REPORT="$REPORT \t Spark worker memory (MB)   \t\t $SPARK_WORKER_MEMORY \n"
	REPORT="$REPORT \t Spark executors per worker   \t\t $SPARK_EXECUTORS_PER_WORKER \n"
	REPORT="$REPORT \t Spark executor cores   \t\t $SPARK_CORES_PER_EXECUTOR \n"
	REPORT="$REPORT \t Spark executor memory (MB)   \t\t $SPARK_EXECUTOR_MEMORY \n"
	REPORT="$REPORT \t Spark executor heapsize (MB) \t\t $SPARK_EXECUTOR_HEAPSIZE \n"
	REPORT="$REPORT \t Spark executor overhead (MB) \t\t $SPARK_EXECUTOR_MEMORY_OVERHEAD \n"
	REPORT="$REPORT \t Spark YARN AM memory (MB) \t\t $SPARK_YARN_AM_MEMORY \n"
	REPORT="$REPORT \t Spark YARN AM heapsize (MB) \t\t $SPARK_YARN_AM_HEAPSIZE \n"
	REPORT="$REPORT \t Spark YARN AM overhead (MB) \t\t $SPARK_YARN_AM_MEMORY_OVERHEAD \n"
	REPORT="$REPORT \t Spark YARN executors per node   \t $SPARK_YARN_EXECUTORS_PER_NODE \n"
	REPORT="$REPORT \t Spark YARN executor cores   \t\t $SPARK_YARN_CORES_PER_EXECUTOR \n"
	REPORT="$REPORT \t Spark YARN executor memory (MB)   \t $SPARK_YARN_EXECUTOR_MEMORY \n"
	REPORT="$REPORT \t Spark YARN executor heapsize (MB) \t $SPARK_YARN_EXECUTOR_HEAPSIZE \n"
	REPORT="$REPORT \t Spark YARN executor overhead (MB) \t $SPARK_YARN_EXECUTOR_MEMORY_OVERHEAD \n"
	REPORT="$REPORT \t Flink TaskManagers per node   \t\t $FLINK_TASKMANAGERS_PER_NODE \n"
	REPORT="$REPORT \t Flink TaskManager slots   \t\t $FLINK_TASKMANAGER_SLOTS \n"
	REPORT="$REPORT \t Flink TaskManager memory network (MB) \t $FLINK_TASKMANAGER_MEMORY_NETWORK_MAX \n"
	REPORT="$REPORT \t Flink JobManager memory (MB) \t\t $FLINK_JOBMANAGER_MEMORY \n"
	REPORT="$REPORT \t Flink TaskManager memory (MB) \t\t $FLINK_TASKMANAGER_MEMORY \n"
	REPORT="$REPORT \t Flink YARN JobManager memory (MB) \t $FLINK_YARN_JOBMANAGER_MEMORY \n"
	REPORT="$REPORT \t Flink YARN TaskManager memory (MB) \t $FLINK_YARN_TASKMANAGER_MEMORY \n"
	REPORT="$REPORT \n Benchmarks: \n"
	echo -e "$REPORT" > $REPORT_FILE
	printf " %-5s \t %-25s \t %-20s \t %-10s\n" 'NODES' 'SOLUTION' 'BENCHMARK' 'RUNTIME(s)' >> $REPORT_FILE

	if [[ $ENABLE_PLOT == "true" ]]
	then
		if [[ ! -f "$PLOT_DIR" ]]
		then
			mkdir -p $PLOT_DIR
		fi
		bash $PLOT_HOME/plot_legend.sh $PLOT_DIR >> $PLOT_DIR/log 2>&1
	fi

	if [[ $ENABLE_OPROFILE == "true" ]]
	then
		if [[ ! -f "$OPROFILE_PLOT_DIR" ]]
		then
			mkdir -p $OPROFILE_PLOT_DIR
		fi
		bash $PLOT_HOME/plot_legend.sh $OPROFILE_PLOT_DIR >> $OPROFILE_PLOT_DIR/log 2>&1
	fi

	if [[ $ENABLE_ILO == "true" ]]
	then
        	if [[ ! -f "$ILO_DIR" ]]
	        then
        	        mkdir -p $ILO_DIR
	        fi

        	file=`basename ${ILO_POWER_SCRIPT_TEMPLATE}`
	        ilo_script_content="$(cat ${ILO_POWER_SCRIPT_TEMPLATE})"
        	ilo_script_content=$(echo -e "${ilo_script_content}" | sed "s/adminname/$ILO_USERNAME/g")
	        ilo_script_content=$(echo -e "${ilo_script_content}" | sed "s/password/$ILO_PASSWD/g")
        	echo "${ilo_script_content}" > ${ILO_DIR}/${file}
	        export ILO_POWER_SCRIPT=${ILO_DIR}/${file}
	fi
}

export -f begin_report

function start_benchmark(){

	if [[ -n "$BENCHMARK_SETUP" ]]
	then
		m_echo "Setting up $BENCHMARK: $BENCHMARK_SETUP"
	
		bash -c "$BENCHMARK_SETUP"
	fi

	WAIT_SECONDS=0
	CURRENT_TIME=`timestamp`
	START_TOTAL_TIME=$(($START_TOTAL_TIME+$CURRENT_TIME))

	if [[ $ENABLE_ILO == "true" ]]
	then
		m_echo "Starting ilo monitors"
		bash $ILO_HOME/start_ilo_monitor.sh
		WAIT_SECONDS=$MONITOR_DELAY_SECONDS
	fi
	if [[ $ENABLE_STAT == "true" ]]
	then
		m_echo "Starting dool monitors"
		bash $STAT_HOME/start_stat_monitor.sh
		WAIT_SECONDS=$MONITOR_DELAY_SECONDS
	fi
	if [[ $ENABLE_RAPL == "true" ]]
	then
		m_echo "Starting rapl monitors"
		bash $RAPL_HOME/start_rapl_monitor.sh
		WAIT_SECONDS=$MONITOR_DELAY_SECONDS
	fi
	if [[ $ENABLE_OPROFILE == "true" ]]
	then
		m_echo "Starting oprofile monitors"
		bash $OPROFILE_HOME/start_oprofile_monitor.sh
		WAIT_SECONDS=$MONITOR_DELAY_SECONDS
	fi
        if [[ $ENABLE_BDWATCHDOG == "true" ]]
        then
		m_echo "Starting bdwatchdog monitors"
		if [[ $BDWATCHDOG_ATOP == "true" ]]
		then
			m_echo "Starting atop daemons"
			bash $BDWATCHDOG_HOME/start_atop_monitor.sh
		fi
		if [[ $BDWATCHDOG_TURBOSTAT == "true" ]]
		then
			m_echo "Starting turbostat daemons"
			bash $BDWATCHDOG_HOME/start_turbostat_monitor.sh
		fi
		if [[ $BDWATCHDOG_NETHOGS == "true" ]]
		then
			m_echo "Starting nethogs daemons"
			bash $BDWATCHDOG_HOME/start_nethogs_monitor.sh
		fi
		WAIT_SECONDS=$MONITOR_DELAY_SECONDS
	fi

	if [[ $WAIT_SECONDS -gt 0 ]]; then
		m_echo "Waiting $WAIT_SECONDS seconds"
		sleep $WAIT_SECONDS
	fi

	if [[ $ENABLE_BDWATCHDOG == "true" ]]; then
		if [[ $BDWATCHDOG_TIMESTAMPING == "true" ]]; then
			### MARK start of workload
			${PYTHON3_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/timestamping/signal_test.py start "$EXPERIMENT_NAME" "$BENCHMARK"_"$i" --username $BDWATCHDOG_USERNAME | \
			${PYTHON3_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/mongodb/mongodb_agent.py
		fi
	fi

	CURRENT_TIME=`timestamp`
	START_TIME=$(($START_TIME+$CURRENT_TIME))
}

export -f start_benchmark

function end_benchmark(){
	CURRENT_TIME=`timestamp`
	END_TIME=$(($END_TIME+$CURRENT_TIME))

	if [[ $ENABLE_BDWATCHDOG == "true" ]]; then
		if [[ $BDWATCHDOG_TIMESTAMPING == "true" ]]; then
		### MARK end of workload
		${PYTHON3_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/timestamping/signal_test.py end "$EXPERIMENT_NAME" "$BENCHMARK"_"$i" --username $BDWATCHDOG_USERNAME | \
		${PYTHON3_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/mongodb/mongodb_agent.py
		fi
	fi

	m_echo "Finished $BENCHMARK"

	if [[ $WAIT_SECONDS -gt 0 ]]
        then
		m_echo "Waiting $WAIT_SECONDS seconds"
                sleep $WAIT_SECONDS
        fi

	if [[ $ENABLE_ILO == "true" ]]
	then
		m_echo "Stopping ilo monitors"
		bash $ILO_HOME/stop_ilo_monitor.sh
	fi
	if [[ $ENABLE_OPROFILE == "true" ]]
	then
		m_echo "Stopping oprofile monitors"
		bash $OPROFILE_HOME/stop_oprofile_monitor.sh
	fi
	if [[ $ENABLE_RAPL == "true" ]]
	then
		m_echo "Stopping rapl monitors"
		bash $RAPL_HOME/stop_rapl_monitor.sh
	fi
	if [[ $ENABLE_STAT == "true" ]]
	then
		m_echo "Stopping dool monitors"
		bash $STAT_HOME/stop_stat_monitor.sh
	fi

	if [[ $ENABLE_BDWATCHDOG == "true" ]]
	then
		m_echo "Stopping bdwatchdog monitors"
		if [[ $BDWATCHDOG_ATOP == "true" ]]
		then
			m_echo "Stopping atop"
			bash $BDWATCHDOG_HOME/stop_atop_monitor.sh
		fi
		if [[ $BDWATCHDOG_TURBOSTAT == "true" ]]
		then
			m_echo "Stopping turbostat"
			bash $BDWATCHDOG_HOME/stop_turbostat_monitor.sh
		fi
		if [[ $BDWATCHDOG_NETHOGS == "true" ]]
		then
			m_echo "Stopping nethogs"
			bash $BDWATCHDOG_HOME/stop_nethogs_monitor.sh
		fi
	fi

	CURRENT_TIME=`timestamp`
	END_TOTAL_TIME=$(($END_TOTAL_TIME+$CURRENT_TIME))

	if [[ $ELAPSED_TIME == "TIMEOUT" ]]
	then
		m_err "TIMEOUT"
	else
		export ELAPSED_TIME=`op "($END_TIME - $START_TIME) / 1000"`
		export ELAPSED_TOTAL_TIME=`op "($END_TOTAL_TIME - $START_TOTAL_TIME) / 1000"`
	fi

	if [[ -n "$BENCHMARK_CLEANUP" ]]
	then
		m_echo "Cleaning up $BENCHMARK: $BENCHMARK_CLEANUP"
	
		bash -c "$BENCHMARK_CLEANUP"
	fi

	if [[ $ENABLE_OPROFILE == "true" ]]
	then
		m_echo "Generating Oprofile data"
		bash $OPROFILE_PLOT_HOME/plot_oprofile.sh >> $OPROFILELOGDIR/log 2>&1
	fi
	if [[ $ENABLE_RAPL == "true" ]]
	then
		m_echo "Generating RAPL data"
		bash $RAPL_PLOT_HOME/plot_rapl.sh >> $RAPLLOGDIR/log 2>&1
	fi
	if [[ $ENABLE_STAT == "true" ]]
	then
		m_echo "Generating dool data"
		bash $STAT_PLOT_HOME/plot_stats.sh >> $STATLOGDIR/log 2>&1
	fi
}

export -f end_benchmark

function run_command_timeout()
{
	local CMD="$*"

    $EXPECT -c "
        set timeout $TIMEOUT
        spawn -noecho bash -c \"set -o pipefail; $CMD 2>&1 | tee $TMPLOGFILE\"
        expect {
            timeout { exit 124 } 
            eof {
				# capture the exit code of the spawn process
                catch wait result
				# exit code is in the 4th position of the 'result' list
                exit [lindex \$result 3]
            }
        }
    "
	
    local exit_code=$?
    
	#124 is the standard POSIX code for Timeout ('timeout' command)
	if [[ $exit_code == 124 ]] ; then 
        ELAPSED_TIME="TIMEOUT"
        return 124
    fi
    
    return $exit_code
}

export -f run_command_timeout

function run_command()
{
	local CMD="$*"	
	# Execute the command and send everything to tee
	bash -c "set -o pipefail; $CMD 2>&1 | tee \"$TMPLOGFILE\""
	local exit_code=$?	
    return $exit_code	
}

export -f run_command

function run_benchmark()
{
	start_benchmark

	local exit_code=0
	
	if [[ $TIMEOUT != 0 ]]; then
		m_echo "Running ${BENCHMARK} (timeout ${TIMEOUT} s): $*"
		run_command_timeout "$*"
		exit_code=$?
	else
		m_echo "Running ${BENCHMARK}: $*"
		run_command "$*"
		exit_code=$?
	fi

	end_benchmark

    if [[ "$ELAPSED_TIME" == "TIMEOUT" ]]; then
        m_warn "Time limit exceeded ($TIMEOUT s)"
        return $exit_code
    fi

    if [[ $exit_code -ne 0 ]]; then
        m_warn "${BENCHMARK} execution failed (exit code: $exit_code)"
        ELAPSED_TIME="FAILED"
        return $exit_code
    fi

    return 0
}

export -f run_benchmark

function save_elapsed_time()
{
	if [[ "$ELAPSED_TIME" == "FAILED" ]]; then
		m_err "${BENCHMARK} failed"
	else
		if [[ "$ELAPSED_TIME" == "TIMEOUT" ]]; then
			m_err "${BENCHMARK} timed out"
			FINISH="true"
		else
			m_echo "Workload runtime: $ELAPSED_TIME seconds"
			m_echo "Total runtime: $ELAPSED_TOTAL_TIME seconds"
		fi

	fi
	echo "$ELAPSED_TIME" > $ELAPSED_TIME_FILE
	ELAPSED_TIMES="$ELAPSED_TIMES $ELAPSED_TIME"
}

export -f save_elapsed_time

function sum () {
	SUM=0
	for VALUE in $*
	do
		SUM=`op "$SUM + $VALUE"`
	done
	echo $SUM
}

export -f sum

function sum_comma () {
	sum `echo $* | tr "," " "`
}

export -f sum_comma

function median () {
	if [[ ! -n "$*" ]]
	then
		COUNT=0
		unset MIDDLE
	else
		COUNT=`echo $* | wc -w`
		MIDDLE=$((1+$COUNT/2))
		MEDIAN=`echo "$*" | xargs -n1 | sort -n | head -n "$MIDDLE" | tail -n 1`
	fi
}

export -f median

function avg () {
	SUM=0
	COUNT=0
	for VALUE in $*
	do
		if [[ "x$VALUE" != "xFAILED" && "x$VALUE" != "xTIMEOUT" ]]
		then		
			SUM=`echo "scale=4; $SUM + $VALUE " | bc`
			COUNT=$(( $COUNT + 1 ))
		fi
	done
	if [ $(echo "$SUM == 0" | bc) -eq 1 ]
	then
		unset AVG
	else
		AVG=`echo "scale=2; $SUM / $COUNT " | bc`
	fi
}

export -f avg

function maxmin () {
	unset MAX
	unset MIN
	for VALUE in $*
	do
		if [[ "x$VALUE" != "xFAILED" && "x$VALUE" != "xTIMEOUT" ]]
		then	
			if [[ -z $MAX || `echo $VALUE'>'$MAX | bc -l` == 1 ]];
			then
				MAX=$VALUE
			fi
			if [[ -z $MIN || `echo $VALUE'<'$MIN | bc -l` == 1 ]];
			then
				MIN=$VALUE
			fi
		fi
	done
}

export -f maxmin

function is_nfs() {
    local target_path="$1"

	if [ -z "$target_path" ]; then
        return 2
    fi
    
	# findmnt will return 0 if it finds it, and 1 if it doesn't
    findmnt -T "$target_path" -n -t nfs,nfs4 >/dev/null 2>&1
    return $?
}

export -f is_nfs
