#!/bin/sh

function get_date {
	DATE=`date '+%y/%m/%d %H:%M:%S'`
}

export -f get_date

function m_echo() {
	get_date
	echo -e "\e[48;5;22m[${METHOD_NAME} $DATE INFO]\e[0m $@" 
	echo "$DATE > $@" >> $REPORT_LOG
}

export -f m_echo

function m_err() {
	get_date
	echo -e "\e[48;5;124m[${METHOD_NAME} $DATE ERR ]\e[0m $@" >&2
	echo "$DATE ! $@" >> $REPORT_LOG
}

export -f m_err

function m_exit() {
	m_err $@
	exit -1
}

export -f m_exit

function print_workload_conf()
{
	m_echo "TestDFSIO num of files: $DFSIO_N_FILES"
	m_echo "TestDFSIO file size (MB): $DFSIO_FILE_SIZE"
	m_echo "WordCount datasize (B): $WORDCOUNT_DATASIZE"
	m_echo "Sort datasize (B): $SORT_DATASIZE"
	m_echo "TeraSort datasize (B): $TERASORT_DATASIZE"
	m_echo "Grep datasize (B): $GREP_DATASIZE"
	m_echo "PageRank pages: $PAGERANK_PAGES"
	m_echo "PageRank iterations: $PAGERANK_MAX_ITERATIONS"
	m_echo "ConCmpt pages: $CC_PAGES"
	m_echo "ConCmpt iterations: $CC_MAX_ITERATIONS"
	m_echo "KMeans num of clusters: $KMEANS_NUM_OF_CLUSTERS"
	m_echo "KMeans dimensions: $KMEANS_DIMENSIONS"
	m_echo "KMeans num of samples: $KMEANS_NUM_OF_SAMPLES"
	m_echo "KMeans samples per file: $KMEANS_SAMPLES_PER_INPUTFILE"
	m_echo "KMeans convergence delta: $KMEANS_CONVERGENCE_DELTA"
	m_echo "KMeans iterations: $KMEANS_MAX_ITERATIONS"
	m_echo "Bayes pages: $BAYES_PAGES"
	m_echo "Bayes clasess: $BAYES_CLASSES"
	m_echo "Bayes ngrams: $BAYES_NGRAMS"
	m_echo "Aggregations pages: $AGGREGATION_PAGES"
	m_echo "Aggregations uservisits: $AGGREGATION_USERVISITS"
	m_echo "Join pages: $JOIN_PAGES"
	m_echo "Join uservisits: $JOIN_USERVISITS"
	m_echo "Scan pages: $SCAN_PAGES"
	m_echo "Scan uservisits: $SCAN_USERVISITS"
}

export -f print_workload_conf


function m_start_message()
{
	m_echo "Reporting to $REPORT_DIR"
	m_echo "Cluster sizes: $CLUSTER_SIZES"
	m_echo "Benchmarks: $BENCHMARKS"
	m_echo "Benchmark executions: $NUM_EXECUTIONS"
	m_echo "Solutions: $SOLUTIONS"
	print_workload_conf	
}

export -f m_start_message

function m_stop_message()
{
	m_echo "Evaluation finished"
	m_echo "Report summary can be found at $REPORT_FILE"
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

function get_num_conf_params(){
	echo $NUM_CONF_PARAMS 
}

export -f get_num_conf_params

function ini_conf_params(){
	export NUM_CONF_PARAMS=0
	CONFIG_KEYS=""
	CONFIG_VALUES=""
}

export -f ini_conf_params

function add_conf_param(){
	NUM_CONF_PARAMS=$(($NUM_CONF_PARAMS + 1))
	CONFIG_KEYS+="\t$1"
	CONFIG_VALUES+="\t$2"
	export CONFIG_KEYS
	export CONFIG_VALUES
	export NUM_CONF_PARAMS
}

export -f add_conf_param

function add_conf_param_list(){
	KEY="$1"
	VALUE=""
	PARAM_LIST="$2"
	FIRST="true"

	for PARAM in $PARAM_LIST
	do
		if [[ "$FIRST" == "true" ]]
		then
			VALUE="${PARAM}"
			FIRST="false"
		else
			VALUE="${VALUE},${PARAM}"
		fi
	done

	add_conf_param "$KEY" "$VALUE"
}

export -f add_conf_param_list

function add_prefix_sufix(){
	RESULT=""
	PARAM_LIST="$1"
	PREFIX="$2"
	SUFIX="$3"

	for PARAM in $PARAM_LIST
	do
		RESULT="${RESULT} ${PREFIX}${PARAM}${SUFIX}"
	done

	echo $RESULT
}

export -f add_prefix_sufix

function get_conf_key(){
	num_param=$1
	echo -e "$CONFIG_KEYS" \
	|  tr -s " " | sed -e 's/^[ \t]*//' \
	| cut -f $num_param
}

export -f get_conf_key

function get_conf_value(){
	num_param=$1
	echo -e "$CONFIG_VALUES" \
	|  tr -s " " | sed -e 's/^[ \t]*//' \
	| cut -f $num_param
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

function get_nodes_by_name() 
{
	NODE_FILE=${1}
        NODES=${*:2}
	IP_NODES=""
	touch $NODE_FILE
        for NODE in $NODES
        do
		OUT=`$RESOLVEIP_COMMAND hosts $NODE`
		NODE_IP=`echo $OUT | cut -d " " -f 1`
		NODE_NAME=`echo $OUT | cut -d " " -f 2`
		IP_NODES="${IP_NODES} ${NODE_IP}"
                echo "$NODE_NAME $NODE_IP" >> $NODE_FILE
        done
        echo $IP_NODES
}

export -f get_nodes_by_name

function get_nodes_by_interface() 
{
	NODE_FILE=${1}
	INTERFACE=${2}
	NODES=${*:3}
	INTERFACE_NODES=""
	touch $NODE_FILE
	for NODE in $NODES
	do
		INTERFACE_IP=`ssh $NODE "$IP_COMMAND addr show" | grep $INTERFACE | grep inet | cut -d ' ' -f 6 | cut -d '/' -f 1 | head -n 1`
		INTERFACE_NODES="${INTERFACE_NODES} ${INTERFACE_IP}"
		echo "$NODE $INTERFACE_IP" >> $NODE_FILE
	done
	echo $INTERFACE_NODES
}

export -f get_nodes_by_interface

function set_network_configuration()
{
	if [[ "${SOLUTION_NET_INTERFACE}" == "gbe" ]]
	then
		if [[ -n ${GBE_COMPUTE_NODES} ]]
		then
			load_nodes ${GBE_COMPUTE_NODES}
			export NET_INTERFACE=$GBE_INTERFACE
			FILE=$NODE_FILE_GBE
		else
			load_nodes ${IP_COMPUTE_NODES}
			FILE=$NODE_FILE
		fi
	else 
		if [[ "${SOLUTION_NET_INTERFACE}" == "ipoib" ]]
		then
			if [[ -n ${IPOIB_COMPUTE_NODES} ]]
			then
				load_nodes ${IPOIB_COMPUTE_NODES}
				export NET_INTERFACE=$IPOIB_INTERFACE
				FILE=$NODE_FILE_IPOIB
			else
				load_nodes ${IP_COMPUTE_NODES}
				FILE=$NODE_FILE
			fi	
		fi
	fi

	add_conf_param "master" $MASTERNODE
	add_conf_param "net_interface" $NET_INTERFACE
	add_conf_param "hostfile" $FILE
}

export -f set_network_configuration

function set_directory_configuration()
{
	mkdir -p $SOL_CONF_DIR
	cp -r $SOL_CONF_DIR_SRC/* $SOL_CONF_DIR
	chmod -R +w $SOL_CONF_DIR
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
	SOLUTION_NAME=`echo $SOLUTION | cut -d '_' -f 1`
	SOLUTION_VERSION=`echo $SOLUTION | cut -d '_' -f 2`
	export SOLUTION_NET_INTERFACE=`echo $SOLUTION | cut -d '_' -f 3 | awk '{print tolower($0)}'`
	export SOLUTION_DIR=${SOLUTIONS_SRC_DIR}/${SOLUTION_NAME}

	if [[ "$SOLUTION_NAME" == "Hadoop-UDA-YARN" ]]
	then
		SOLUTION_NAME="Hadoop-YARN"
	elif [[ "$SOLUTION_NAME" == "Spark-YARN" ]]
	then
		SOLUTION_NAME="Spark"
	elif [[ "$SOLUTION_NAME" == "Flink-YARN" ]]
	then
		SOLUTION_NAME="Flink"
	elif [[ "$SOLUTION_NAME" == "RDMA-Spark-YARN" ]]
	then
		SOLUTION_NAME="RDMA-Spark"
	fi

	export SOLUTION_HOME=${SOLUTIONS_DIST_DIR}/${SOLUTION_NAME}/${SOLUTION_VERSION}
	export SOLUTION_REPORT_DIR=${CLUSTER_SIZE_REPORT_DIR}/${SOLUTION}

	if [[ ! -d $SOLUTION_HOME ]]
	then
		m_exit "Solution $SOLUTION not found at $SOLUTION_HOME"
	else
		m_echo "Solution set to $SOLUTION: $SOLUTION_HOME"
	fi

	if [[ "$SOLUTION_NAME" == "Spark" || "$SOLUTION_NAME" == "RDMA-Spark" ]]
        then
                if [[ ! -d $SPARK_HADOOP_HOME ]]
                then
                        m_exit "Hadoop distribution not found at $SPARK_HADOOP_HOME"
                fi
	elif [[ "$SOLUTION_NAME" == "Flink" ]]
        then
                if [[ ! -d $FLINK_HADOOP_HOME ]]
                then
                        m_exit "Hadoop distribution not found at $FLINK_HADOOP_HOME"
                fi
	elif [[ "$SOLUTION_NAME" == "FlameMR" ]]
        then
                if [[ ! -d $FLAMEMR_HADOOP_HOME ]]
                then
                        m_exit "Hadoop distribution not found at $FLAMEMR_HADOOP_HOME"
                fi
	elif [[ "$SOLUTION_NAME" == "DataMPI" ]]
        then
                if [[ ! -d $DATAMPI_HADOOP_HOME ]]
                then
                        m_exit "Hadoop distribution not found at $DATAMPI_HADOOP_HOME"
                fi
	fi

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
	printf " %-5s \t %-25s \t %-20s \t %-10s\n" $CLUSTER_SIZE $SOLUTION $BENCHMARK $ELAPSED_TIMES >> $REPORT_FILE

	if [[ $ENABLE_PLOT == "true" ]]
	then
		m_echo "Generating performance graphs"
		if [[ ! -f "$PLOT_DIR" ]]
		then
			mkdir -p $PLOT_DIR
		fi
		bash $PLOT_HOME/plot_benchmark.sh >> $PLOT_DIR/log 2>&1
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
	REPORT="$METHOD_NAME report file \n"
	REPORT="$REPORT Start date: $METHOD_START_DATE \n"
	REPORT="$REPORT \n $METHOD_NAME configuration: \n"
	REPORT="$REPORT \t Cluster nodes  \t\t\t $MASTERNODE $SLAVENODES \n"
	REPORT="$REPORT \t Cluster sizes  \t\t\t $CLUSTER_SIZES \n"
	REPORT="$REPORT \t Benchmarks  \t\t\t\t $BENCHMARKS \n"
	REPORT="$REPORT \t Benchmark executions  \t\t\t $NUM_EXECUTIONS \n"
	REPORT="$REPORT \t Solutions  \t\t\t\t $SOLUTIONS \n"
	REPORT="$REPORT \t TestDFSIO num of files \t\t $DFSIO_N_FILES \n"
	REPORT="$REPORT \t TestDFSIO file size (MB) \t\t $DFSIO_FILE_SIZE \n"
	REPORT="$REPORT \t WordCount datasize (B) \t\t $WORDCOUNT_DATASIZE \n"
	REPORT="$REPORT \t Sort datasize (B) \t\t\t $SORT_DATASIZE \n"
	REPORT="$REPORT \t TeraSort datasize (B) \t\t\t $TERASORT_DATASIZE \n"
	REPORT="$REPORT \t Grep datasize (B) \t\t\t $GREP_DATASIZE \n"
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
	if [[ -n $GBE_INTERFACE ]]
	then
		REPORT="$REPORT \t GbE interface  \t\t\t $GBE_INTERFACE \n"
	else
		REPORT="$REPORT \t GbE interface  \t\t\t Not specified \n"
	fi
	if [[ -n $IPOIB_INTERFACE ]]
	then
		REPORT="$REPORT \t IPoIB interface  \t\t\t $IPOIB_INTERFACE \n"
	else
		REPORT="$REPORT \t IPoIB interface  \t\t\t Not specified \n"
	fi
	REPORT="$REPORT \t Cores per node \t\t\t $CORES_PER_NODE \n"
	REPORT="$REPORT \t Memory per node (MB) \t\t\t $MEMORY_PER_NODE \n"
	REPORT="$REPORT \t Master heapsize (MB) \t\t\t $MASTER_HEAPSIZE \n"
	REPORT="$REPORT \t Slave heapsize (MB)  \t\t\t $SLAVE_HEAPSIZE \n"
	REPORT="$REPORT \t YARN NodeManager vcores  \t\t $NODEMANAGER_VCORES \n"
	REPORT="$REPORT \t YARN NodeManager memory (MB)  \t\t $NODEMANAGER_MEMORY \n"
	REPORT="$REPORT \t YARN APPMaster memory (MB)  \t\t $APP_MASTER_MEMORY \n"
	REPORT="$REPORT \t YARN APPMaster heapsize (MB) \t\t $APP_MASTER_HEAPSIZE \n"
	REPORT="$REPORT \t YARN Container memory (MB) \t\t $CONTAINER_MEMORY \n"
	REPORT="$REPORT \t HDFS block size (B)  \t\t\t $BLOCKSIZE \n"
	REPORT="$REPORT \t HDFS replication factor  \t\t $REPLICATION_FACTOR \n"
	REPORT="$REPORT \t HDFS NameNode handlers \t\t $NAMENODE_HANDLER_COUNT \n"
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
	REPORT="$REPORT \t DataMPI task heapsize (MB)   \t\t $DATAMPI_TASK_HEAPSIZE \n"
	REPORT="$REPORT \t Flame-MR workers per node   \t\t $FLAMEMR_WORKERS_PER_NODE \n"
	REPORT="$REPORT \t Flame-MR cores per worker   \t\t $FLAMEMR_CORES_PER_WORKER \n"
	REPORT="$REPORT \t Flame-MR worker memory   \t\t $FLAMEMR_WORKER_MEMORY \n"
	REPORT="$REPORT \t Flame-MR memory buffer size   \t\t $FLAMEMR_BUFFER_SIZE \n"
	REPORT="$REPORT \t Flame-MR debug mode   \t\t\t $FLAMEMR_DEBUG_MODE \n"
	REPORT="$REPORT \t Flame-MR iterative mode   \t\t $FLAMEMR_ITERATIVE_MODE \n"
	REPORT="$REPORT \t Spark driver cores   \t\t\t $SPARK_DRIVER_CORES \n"
	REPORT="$REPORT \t Spark driver heapsize (MB)   \t\t $SPARK_DRIVER_HEAPSIZE \n"
	REPORT="$REPORT \t Spark Workers per node   \t\t $SPARK_WORKERS_PER_NODE \n"
	REPORT="$REPORT \t Spark Worker cores   \t\t\t $SPARK_WORKER_CORES \n"
	REPORT="$REPORT \t Spark Worker memory (MB)   \t\t $SPARK_WORKER_MEMORY \n"
	REPORT="$REPORT \t Spark executors per Worker   \t\t $SPARK_EXECUTORS_PER_WORKER \n"
	REPORT="$REPORT \t Spark executor cores   \t\t $SPARK_CORES_PER_EXECUTOR \n"
	REPORT="$REPORT \t Spark executor memory (MB)   \t\t $SPARK_EXECUTOR_MEMORY \n"
	REPORT="$REPORT \t Spark executor heapsize (MB) \t\t $SPARK_EXECUTOR_HEAPSIZE \n"
	REPORT="$REPORT \t Spark YARN executors per node   \t $SPARK_YARN_EXECUTORS_PER_NODE \n"
	REPORT="$REPORT \t Spark YARN executor cores   \t\t $SPARK_YARN_CORES_PER_EXECUTOR \n"
	REPORT="$REPORT \t Spark YARN executor memory (MB)   \t $SPARK_YARN_EXECUTOR_MEMORY \n"
	REPORT="$REPORT \t Spark YARN executor heapsize (MB) \t $SPARK_YARN_EXECUTOR_HEAPSIZE \n"
	REPORT="$REPORT \t Flink TaskManagers per node   \t\t $FLINK_TASKMANAGERS_PER_NODE \n"
	REPORT="$REPORT \t Flink TaskManager slots   \t\t $FLINK_TASKMANAGER_SLOTS \n"
	REPORT="$REPORT \t Flink TaskManager preallocate memory \t $FLINK_TASKMANAGER_PREALLOCATE_MEMORY \n"
	REPORT="$REPORT \t Flink JobManager heapsize (MB) \t $FLINK_JOBMANAGER_HEAPSIZE \n"
	REPORT="$REPORT \t Flink TaskManager memory (MB) \t\t $FLINK_TASKMANAGER_MEMORY \n"
	REPORT="$REPORT \t Flink TaskManager heapsize (MB) \t $FLINK_TASKMANAGER_HEAPSIZE \n"
	REPORT="$REPORT \t Flink YARN JobManager heapsize (MB) \t $FLINK_YARN_JOBMANAGER_HEAPSIZE \n"
	REPORT="$REPORT \t Flink YARN TaskManager memory (MB) \t $FLINK_YARN_TASKMANAGER_MEMORY \n"
	REPORT="$REPORT \t Flink YARN TaskManager heapsize (MB) \t $FLINK_YARN_TASKMANAGER_HEAPSIZE \n"
	REPORT="$REPORT \n $METHOD_NAME results: \n\n"
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
        	ilo_script_content=$(echo -e "${ilo_script_content}" | sed "s/adminname/ilo_user/g")
	        ilo_script_content=$(echo -e "${ilo_script_content}" | sed "s/password/..ilo_user../g")
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

	WAIT_SECONDS=""
	if [[ $ENABLE_ILO == "true" ]]
	then
		maxmin $ILO_WAIT_SECONDS $WAIT_SECONDS
		WAIT_SECONDS=$MAX
	fi
	if [[ $ENABLE_STAT == "true" ]]
	then 
		maxmin $STAT_WAIT_SECONDS $WAIT_SECONDS
		WAIT_SECONDS=$MAX
	fi
	if [[ $ENABLE_RAPL == "true" ]]
	then 
		maxmin $RAPL_WAIT_SECONDS $WAIT_SECONDS
		WAIT_SECONDS=$MAX
	fi
	if [[ $ENABLE_OPROFILE == "true" ]]
	then 
		maxmin $OPROFILE_WAIT_SECONDS $WAIT_SECONDS
		WAIT_SECONDS=$MAX
	fi
	if [[ $ENABLE_BDWATCHDOG == "true" ]]
        then
		maxmin $BDWATCHDOG_WAIT_SECONDS $WAIT_SECONDS
                WAIT_SECONDS=$MAX
	fi

	if [[ -n "$WAIT_SECONDS" ]]
	then
		m_echo "Waiting $WAIT_SECONDS seconds"
		sleep $WAIT_SECONDS
	fi

	WAIT_SECONDS=""
	if [[ $ENABLE_ILO == "true" ]]
	then
		m_echo "Starting ilo monitors"
		bash $ILO_HOME/start_ilo_monitor.sh
		maxmin $ILO_SECONDS_INTERVAL $WAIT_SECONDS
                WAIT_SECONDS=$MAX
	fi
	if [[ $ENABLE_STAT == "true" ]]
	then
		m_echo "Starting dstat monitors"
		bash $STAT_HOME/start_stat_monitor.sh
		maxmin $STAT_SECONDS_INTERVAL $WAIT_SECONDS
                WAIT_SECONDS=$MAX
	fi
	if [[ $ENABLE_RAPL == "true" ]]
	then
		m_echo "Starting rapl monitors"
		bash $RAPL_HOME/start_rapl_monitor.sh
		maxmin $RAPL_SECONDS_INTERVAL $WAIT_SECONDS
                WAIT_SECONDS=$MAX
	fi
	if [[ $ENABLE_OPROFILE == "true" ]]
	then
		m_echo "Starting oprofile monitors"
		bash $OPROFILE_HOME/start_oprofile_monitor.sh
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
		maxmin $BDWATCHDOG_SECONDS_INTERVAL $WAIT_SECONDS
                WAIT_SECONDS=$MAX
	fi

	if [[ -n "$WAIT_SECONDS" ]]
	then
		sleep $WAIT_SECONDS
	fi

	if [[ $ENABLE_BDWATCHDOG == "true" ]]; then
		if [[ $BDWATCHDOG_TIMESTAMPING == "true" ]]; then
		### MARK start of workload
		${PYTHON3_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/timestamping/signal_test.py start "$EXPERIMENT_NAME" "$BENCHMARK"_"$i" --username $BDWATCHDOG_USERNAME | \
		${PYTHON3_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/mongodb/mongodb_agent.py
		fi
	fi

	m_echo "Starting $BENCHMARK"
	START_TIME=`timestamp`
}

export -f start_benchmark

function end_benchmark(){
	END_TIME=`timestamp`

	if [[ $ENABLE_BDWATCHDOG == "true" ]]; then
		if [[ $BDWATCHDOG_TIMESTAMPING == "true" ]]; then
		### MARK end of workload
		${PYTHON3_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/timestamping/signal_test.py end "$EXPERIMENT_NAME" "$BENCHMARK"_"$i" --username $BDWATCHDOG_USERNAME | \
		${PYTHON3_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/mongodb/mongodb_agent.py
		fi
	fi

	if [[ -n "$WAIT_SECONDS" ]]
        then
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
		m_echo "Stopping dstat monitors"
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

	if [[ $ELAPSED_TIME == "TIMEOUT" ]]
	then
		m_err "TIMEOUT"
	else
		export ELAPSED_TIME=`op "($END_TIME - $START_TIME) / 1000"`
	fi
	m_echo "Finished $BENCHMARK"

	if [[ -n "$BENCHMARK_CLEANUP" ]]
	then
		m_echo "Cleaning up $BENCHMARK: $BENCHMARK_CLEANUP"
	
		bash -c "$BENCHMARK_CLEANUP"
	fi

	if [[ $ENABLE_OPROFILE == "true" ]]
	then
		bash $OPROFILE_PLOT_HOME/plot_oprofile.sh >> $OPROFILELOGDIR/log 2>&1
	fi
	if [[ $ENABLE_RAPL == "true" ]]
	then
		bash $RAPL_PLOT_HOME/plot_rapl.sh >> $RAPLLOGDIR/log 2>&1
	fi
	if [[ $ENABLE_STAT == "true" ]]
	then
		bash $STAT_PLOT_HOME/plot_stats.sh >> $STATLOGDIR/log 2>&1
	fi
}

export -f end_benchmark

################################################################################
# Executes command with a timeout
# Params:
#   $* commands to execute
# Returns 1 if timed out 0 otherwise
function run_command_timeout()
{
	CMD="/bin/sh -c \"$*\""

	expect -c \
	"set echo -noecho; set timeout $TIMEOUT; spawn -noecho $CMD; expect timeout { exit 1 } eof { exit 0 }"

	if [[ $? == 1 ]] ; then ELAPSED_TIME="TIMEOUT" ; fi
}

export -f run_command_timeout

function run_command()
{
	/bin/sh -c "$*"
}

export -f run_command

function run_benchmark()
{
	start_benchmark

	if [[ $TIMEOUT != 0 ]]
	then
		run_command_timeout "{ $*; } 2>&1 | tee $TMPLOGFILE"
	else
		run_command "$* 2>&1 | tee $TMPLOGFILE"
	fi

	end_benchmark
}

export -f run_benchmark

function save_elapsed_time()
{
	if [[ "$ELAPSED_TIME" == "FAILED" ]]
	then
		m_err "${BENCHMARK} failed"
	else
		if [[ "$ELAPSED_TIME" == "TIMEOUT" ]]
		then
			m_err "${BENCHMARK} timed out"
			FINISH="true"
		else
			m_echo "Runtime: $ELAPSED_TIME s"
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

