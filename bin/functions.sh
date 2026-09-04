#!/bin/bash

function get_date() {
	printf -v DATE '%(%d/%m/%Y %H:%M:%S)T' -1
}

export -f get_date

function m_echo() {
	get_date
	printf '\e[48;5;2m[%s INFO]\e[0m %s\n' "$DATE" "$*"
	[[ -n "$REPORT_LOG" ]] && printf '%s > %s\n' "$DATE" "$*" >> "$REPORT_LOG"
}

export -f m_echo

function m_error() {
	get_date
	printf '\e[48;5;1m[%s ERR ]\e[0m %s\n' "$DATE" "$*" >&2
	[[ -n "$REPORT_LOG" ]] && printf '%s ! %s\n' "$DATE" "$*" >> "$REPORT_LOG"
}

export -f m_error

function m_warn() {
	get_date
	printf '\e[48;5;208m[%s WARN]\e[0m %s\n' "$DATE" "$*"
	[[ -n "$REPORT_LOG" ]] && printf '%s ! %s\n' "$DATE" "$*" >> "$REPORT_LOG"
}

export -f m_warn

function m_exit() {
	m_error "$@"
	
	if [[ "$CLEANUP_ON_EXIT" == "true" ]]; then
		[[ -f "$CLEANUP_YARN_SCRIPT" ]] && bash "$CLEANUP_YARN_SCRIPT"
		[[ -f "$CLEANUP_PROCESS_SCRIPT" ]] && bash "$CLEANUP_PROCESS_SCRIPT"
	fi

	exit 1
}

export -f m_exit

function m_start_message() {
	m_echo "Frameworks directory: $BDEV_FRAMEWORKS_DIR"
	if [[ ${NUM_SOLUTIONS:-0} -gt 0 ]]; then
		m_echo "Frameworks ($NUM_SOLUTIONS): $SOLUTIONS"
	fi
	if [[ ${NUM_BENCHMARKS:-0} -gt 0 ]]; then
		m_echo "Benchmarks ($NUM_BENCHMARKS): $BENCHMARKS"
	fi
	m_echo "Benchmark executions: $NUM_EXECUTIONS"
	m_echo "Cluster sizes ($NUM_CLUSTERS): $CLUSTER_SIZES"
	m_echo "Storage backend: $STORAGE_BACKEND"
	if [[ "${STORAGE_BACKEND,,}" == "nfs" ]]; then
		m_echo "NFS mount point: $NFS_MOUNT_POINT"
	fi
	m_echo "JVM: $BDEV_JAVA_HOME"
	m_echo "Python: $PYTHON_BIN"
}

export -f m_start_message

function m_stop_message() {
	m_echo "$APP_NAME v$APP_VERSION finished"
	m_echo "Report summary stored at $REPORT_FILE"
}

export -f m_stop_message

function op() {
	local res
	res=$(printf '%s\n' "scale=4; ($*)/1" | bc)
	# Add the initial 0 if the result is less than 1 (positive or negative)
	[[ $res == .* ]] && res="0$res"
	[[ $res == -.* ]] && res="-0${res#-}"
	printf '%s\n' "$res"
}

export -f op

function op_int() {
	printf '%s\n' "scale=0; ($*)/1" | bc
}

export -f op_int

function timestamp() {
    printf '%s\n' "$(( $(date +%s%N) / 1000000 ))"
}

export -f timestamp

function read_list() {
	local file="$1"
	[[ ! -f "$file" ]] && return 0
	
	local values=""
	local line
	while read -r line || [[ -n "$line" ]]; do
		# Remove comments and spaces at the beginning/end
		local val="${line%%#*}"
		# Native array: trims spaces/tabs and separates tokens if there are several
		local fields=($val)
		
		if [[ ${#fields[@]} -gt 0 ]]; then
            		values="${values:+$values }${fields[*]}"
        	fi
	done < "$file"

	echo "$values"
}

export -f read_list

function read_frameworks_list() {
	local file="$1"
	[[ ! -f "$file" ]] && return 0
	
	local values=""
	local line
	while read -r line || [[ -n "$line" ]]; do
		# Remove comments and spaces at the beginning/end
		local val="${line%%#*}"
		# Native array: trims spaces/tabs and separates tokens if there are several
		local fields=($val)
		
		if [[ ${#fields[@]} -gt 0 ]]; then
			local framework="${fields[0]}"
            		local version="${fields[1]}"
            		local network="${fields[2]}"
            		values="${values:+$values }${framework}_${version}_${network}"
		fi
	done < "$file" 

	echo "$values"
}

export -f read_frameworks_list

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

function load_hostfile() {
	local nodes_source=""
	local raw_nodes=""

	if [[ -n "${BDEV_HOSTFILE:-}" ]]; then
		if [[ ! -f "$BDEV_HOSTFILE" ]]; then
			m_exit "BDEV_HOSTFILE is defined but does not exist: $BDEV_HOSTFILE"
		fi
	
		nodes_source="hostfile '$BDEV_HOSTFILE'"
		raw_nodes=$(awk '{print $1}' "$BDEV_HOSTFILE")
	elif [[ "$SLURM_ENV" == "true" ]]; then
		if [[ -z "${SLURM_JOB_NODELIST:-}" ]]; then
			m_exit "Running under Slurm, but SLURM_JOB_NODELIST is empty"
	        fi
        
	        nodes_source="Slurm allocation (\$SLURM_JOB_NODELIST='$SLURM_JOB_NODELIST')"
		raw_nodes=$(scontrol show hostname "$SLURM_JOB_NODELIST")
	else
		m_exit "No hostfile available: BDEV_HOSTFILE is not defined and Slurm allocation was not detected"
	fi

	if [[ -z "${raw_nodes}" ]]; then
	    m_exit "Nodes extracted from $nodes_source is empty. Please verify your configuration"
	fi

	export HOSTFILE_REPORT="$REPORT_DIR/hostfile"
	# Run without 'export' on the same line so as not to mask the exit status
	COMPUTE_NODES=$(get_nodes_by_hostname "$HOSTFILE_REPORT" "$raw_nodes")
	PARSE_STATUS=$?

	if [[ $PARSE_STATUS -ne 0 || -z "${COMPUTE_NODES}" ]]; then
		m_exit "Network resolution failed while processing nodes from $nodes_source"
	fi

	export COMPUTE_NODES
	export NUM_NODES=$(echo "$COMPUTE_NODES" | wc -w)
	m_echo "Nodes from hostfile ($NUM_NODES): $COMPUTE_NODES"

	# Check connectivity to validate SSH and the network (fail fast)
	FIRST_NODE="${COMPUTE_NODES%% *}"
	check_ssh_connectivity "$FIRST_NODE"

	# Enable cleanup on exit
	export CLEANUP_ON_EXIT="true"

	if [[ -n "${ETHERNET_INTERFACE:-}" ]]; then
		export HOSTFILE_ETHERNET="$REPORT_DIR/hostfile.ethernet"
	
		ETHERNET_COMPUTE_NODES=$(get_nodes_by_interface "$HOSTFILE_ETHERNET" "$ETHERNET_INTERFACE" $COMPUTE_NODES)
		ETH_STATUS=$?
	
		if [[ $ETH_STATUS -ne 0 || -z "${ETHERNET_COMPUTE_NODES}" ]]; then
			export ETHERNET_COMPUTE_NODES=""
			rm -f "$HOSTFILE_ETHERNET"
			m_warn "Ethernet ($ETHERNET_INTERFACE): interface validation failed across nodes; interface will be ignored"
		else
			export ETHERNET_COMPUTE_NODES
			m_echo "Ethernet ($ETHERNET_INTERFACE): $ETHERNET_COMPUTE_NODES"
		fi
	fi

	if [[ -n "${IPOIB_INTERFACE:-}" ]]; then
		export HOSTFILE_IPOIB="$REPORT_DIR/hostfile.ipoib"
		
		IPOIB_COMPUTE_NODES=$(get_nodes_by_interface "$HOSTFILE_IPOIB" "$IPOIB_INTERFACE" $COMPUTE_NODES)
		IB_STATUS=$?
       	
		if [[ $IB_STATUS -ne 0 || -z "${IPOIB_COMPUTE_NODES}" ]]; then
			export IPOIB_COMPUTE_NODES=""
			rm -f "$HOSTFILE_IPOIB"
			m_warn "IPoIB ($IPOIB_INTERFACE): interface validation failed across nodes; interface will be ignored"
		else
			export IPOIB_COMPUTE_NODES
			m_echo "IPoIB ($IPOIB_INTERFACE): $IPOIB_COMPUTE_NODES"
		fi
	fi

	if [[ -z "${ETHERNET_COMPUTE_NODES:-}" && -z "${IPOIB_COMPUTE_NODES:-}" ]]; then
		m_warn "No valid network interface configured. Using default network configuration"
	fi

	# Load nodes from default hostfile
	configure_nodes $COMPUTE_NODES

	# Replace MAX in CLUSTER_SIZES (if needed)
	export CLUSTER_SIZES=$(sed "s/MAX/$MAX_NODES/gI" <<< "$CLUSTER_SIZES")
}

export -f load_hostfile

function get_nodes_by_hostname() {
	local node_file="$1"
	shift
	local nodes="$*"
	local tmp_file="${node_file}.tmp"
	local out_nodes=()
	
	> "$tmp_file"
	
        for node in $nodes; do
        	local node_ip=""
        	local node_name=""
        	
        	if [[ "$node" == "localhost" || "$node" == "$LOOPBACK_IP" ]]; then
        		node_ip="$LOOPBACK_IP"
        		node_name="$node"
        	else
        		local out
        		local resolve_status
        		out=$($RESOLVEIP_COMMAND hosts "$node" 2>&1)
			resolve_status=$?
			
			if [[ $resolve_status -ne 0 || -z "$out" ]]; then
				m_error "Could not resolve hostname for node: '$node'"
				m_error "Command failed: $RESOLVEIP_COMMAND hosts \"$node\" (exit code: $resolve_status)"
				[[ -n "$out" ]] && m_error "Details: $out"
				rm -f "$tmp_file"
				return 1
			fi
            
			node_ip=$(awk '{print $1}' <<< "$out")
			node_name=$(awk '{print $2}' <<< "$out")
		fi
		
		if [[ "${ENABLE_HOSTNAMES}" == "true" ]]; then
			out_nodes+=("$node_name")
		else
			out_nodes+=("$node_ip")
		fi

                echo "$node_name $node_ip" >> "$tmp_file"
        done

	# Consolidate the file
	mv "$tmp_file" "$node_file"
        echo "${out_nodes[*]}"
        return 0
}

export -f get_nodes_by_hostname

function get_nodes_by_interface() {
	local node_file="$1"
	local interface="$2"
	shift 2
	local nodes="$*"
	local tmp_file="${node_file}.tmp"
	local out_nodes=()
	local resolution_warning=0
	
	> "$tmp_file"
	
        for node in $nodes; do
        	# Obtain data from the remote interface via SSH
        	local interface_data
        	interface_data=$($SSH_CMD "$node" "$IP_COMMAND a s $interface" 2>/dev/null | grep 'inet ')
        	
        	if [[ -z "$interface_data" ]]; then
        		m_error "Interface '$interface' not found or inactive on node '$node'"
			rm -f "$tmp_file"
			return 1
                fi
                
                # Extract the clean IP address (without CIDR mask)
                local interface_ip
                interface_ip=$(echo "$interface_data" | awk '{print $2}' | cut -d '/' -f 1 | head -n 1)
                
                if [[ -z "$interface_ip" ]]; then
                	m_error "Could not parse IPv4 address for interface '$interface' on node '$node'"
                	rm -f "$tmp_file"
                	return 1
                fi
                
                # Reverse resolution (IP -> Hostname)
                local out
                local node_ip
                local node_name
                out=$($RESOLVEIP_COMMAND hosts "$interface_ip" 2>/dev/null)
                
                if [[ -z "$out" ]]; then
                	# In clusters it is common for interfaces like ib0 not to have reverse PTR registration; we degrade with warning without aborting execution
                        resolution_warning=1
                        node_ip="$interface_ip"
                        node_name="$node"
                else
                        node_ip=$(awk '{print $1}' <<< "$out")
                        node_name=$(awk '{print $2}' <<< "$out")
                fi

                if [[ "${ENABLE_HOSTNAMES}" == "true" ]]; then
                        out_nodes+=("$node_name")
                else
                        out_nodes+=("$node_ip")
                fi

                echo "$node_name $node_ip" >> "$tmp_file"
        done

	# If all nodes responded, we consolidate the file
	mv "$tmp_file" "$node_file"
	
	if [[ $resolution_warning -eq 1 ]]; then
		m_warn "Reverse resolution failed for some nodes on interface '$interface'. Using base hostnames as fallback"
    	fi
    
	echo "${out_nodes[*]}"
	return 0
}

export -f get_nodes_by_interface

function configure_nodes()  {
	export MASTERNODE="$1"
    	shift
    	
    	if [[ $# -eq 0 ]]; then
        	export SLAVENODES="$MASTERNODE"
        	export MAX_NODES=2
    	else
        	export SLAVENODES="$*"
        	export MAX_NODES=$(( $# + 1 ))
    	fi
}

export -f configure_nodes

function configure_network() {
	local nodes
	local net_interface
	local file
	
	if [[ "${SOLUTION}" == "NONE" ]]; then
		nodes="$COMPUTE_NODES"
		net_interface=default
		file="$HOSTFILE_REPORT"
	else
		case "$SOLUTION_NET_INTERFACE" in
		    ethernet)
                	if [[ -n "${ETHERNET_COMPUTE_NODES:-}" ]]; then
                    		nodes="$ETHERNET_COMPUTE_NODES"
                    		net_interface="$ETHERNET_INTERFACE"
                    		file="$HOSTFILE_ETHERNET"
                	else
                    		nodes="$COMPUTE_NODES"
                    		net_interface=default
                    		file="$HOSTFILE_REPORT"
                	fi
                	;;
            	    ipoib|ib|roce)
                	if [[ -n "${IPOIB_COMPUTE_NODES:-}" ]]; then
                    		nodes="$IPOIB_COMPUTE_NODES"
                    		net_interface="$IPOIB_INTERFACE"
                    		file="$HOSTFILE_IPOIB"
                	else
                    		nodes="$COMPUTE_NODES"
                    		net_interface=default
                    		file="$HOSTFILE_REPORT"
                	fi
                	;;

            	    *)
                	m_exit "Invalid network interface '$SOLUTION_NET_INTERFACE' for $SOLUTION. Revise the configured frameworks (framework.lst)"
                	;;
        	esac
        fi
    
	configure_nodes $nodes
	export NETWORK_INTERFACE="$net_interface"
	export HOSTFILE="$file"
		
	if [[ ! -f ${HOSTFILE} ]]; then
		m_exit "Hostfile for $SOLUTION does not exist: $HOSTFILE"
	fi

	if [[ -z ${NETWORK_INTERFACE} ]]; then
		m_exit "Invalid network interface for $SOLUTION. Revise network settings"
	fi

	export RDMA_HADOOP_IB_ENABLED=false
	export RDMA_HADOOP_ROCE_ENABLED=false
		
	if [[ "${SOLUTION_NET_INTERFACE}" == "ib" ]]; then
		m_echo "Using RDMA interface '$RDMA_INTERFACE' for InfiniBand and hostfile: $HOSTFILE"
		export RDMA_HADOOP_IB_ENABLED=true
	elif [[ "${SOLUTION_NET_INTERFACE}" == "roce" ]]; then
		m_echo "Using RDMA interface '$RDMA_INTERFACE' for RoCE and hostfile: $HOSTFILE"
		export RDMA_HADOOP_ROCE_ENABLED=true
	elif [[ "${SOLUTION_NET_INTERFACE}" == "ethernet" ]]; then
		m_echo "Using network interface '$NETWORK_INTERFACE' for TCP/IP over Ethernet and hostfile: $HOSTFILE"
	elif [[ "${SOLUTION_NET_INTERFACE}" == "ipoib" ]]; then
		m_echo "Using network interface '$NETWORK_INTERFACE' for IP over InfiniBand (IPoIB) and hostfile: $HOSTFILE"
	else
		m_exit "Invalid network interface '${SOLUTION_NET_INTERFACE}' for $SOLUTION. Revise the configured frameworks (framework.lst)"
	fi
	
	export MASTERIP=$($BDEV_BIN_DIR/get_ip_from_hostname.sh $HOSTFILE)
}

export -f configure_network

function set_directory_configuration() {
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

function set_cluster_size() {
	export CLUSTER_SIZE
	export SLAVES_NUMBER=$((CLUSTER_SIZE - 1))
	export CLUSTER_SIZE_REPORT_DIR=$REPORT_DIR/${CLUSTER_SIZE}
	m_echo "Cluster size set to $CLUSTER_SIZE"
}

export -f set_cluster_size

function set_framework() {
	export SOLUTION
	export SOLUTION_NAME=$(echo $SOLUTION | cut -d '_' -f 1)
	export SOLUTION_VERSION=$(echo $SOLUTION | cut -d '_' -f 2)
	export SOLUTION_NET_INTERFACE=$(echo $SOLUTION | cut -d '_' -f 3 | awk '{print tolower($0)}')
	export SOLUTION_DIR="${SOLUTIONS_SRC_DIR}/${SOLUTION_NAME}"
	SOLUTION_NUM=$1

	if [[ "$SOLUTION_NAME" == "Spark-YARN" ]]; then
		SOLUTION_NAME="Spark"
	elif [[ "$SOLUTION_NAME" == "Flink-YARN" ]]; then
		SOLUTION_NAME="Flink"
	fi

	export SOLUTION_HOME=${BDEV_FRAMEWORKS_DIR}/${SOLUTION_NAME}/${SOLUTION_VERSION}
	export SOLUTION_REPORT_DIR=${CLUSTER_SIZE_REPORT_DIR}/${SOLUTION}

	if [[ ! -d $SOLUTION_HOME ]]; then
		m_exit "Framework $SOLUTION not found at $SOLUTION_HOME"
	else
		m_echo "Framework set to $SOLUTION: $SOLUTION_HOME"
	fi

	if [[ "$SOLUTION_NAME" == "Spark" ]]; then
        if [[ "${STORAGE_BACKEND,,}" == "hdfs" ]]  && [[ ! -d $SPARK_HADOOP_HOME ]]; then
            m_exit "Hadoop distribution not found at $SPARK_HADOOP_HOME"
        fi
		HADOOP_VERSION=`echo ${SPARK_HADOOP_HOME##*/}`
	elif [[ "$SOLUTION_NAME" == "Flink" ]]; then
        if [[ "${STORAGE_BACKEND,,}" == "hdfs" ]]  && [[ ! -d $FLINK_HADOOP_HOME ]]; then
            m_exit "Hadoop distribution not found at $FLINK_HADOOP_HOME"
        fi
		HADOOP_VERSION=`echo ${FLINK_HADOOP_HOME##*/}`
	elif [[ "$SOLUTION_NAME" == "RDMA-Hadoop-3" ]]; then
		if [[ "${SOLUTION_NET_INTERFACE}" == "ethernet" ]]; then
			m_warn "RDMA-Hadoop-3 configured to use TCP/IP over Ethernet instead of RDMA"
		elif [[ "${SOLUTION_NET_INTERFACE}" == "ipoib" ]]; then
			m_warn "RDMA-Hadoop-3 configured to use IP over InfiniBand (IPoIB) instead of RDMA"
		fi
		HADOOP_VERSION=$SOLUTION_VERSION
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

export -f set_framework

function set_no_framework() {
	m_warn "No framework was configured. Running in command mode"
	export SOLUTIONS=""
	export SOLUTION=NONE
	export BENCHMARKS=command
	export GEN_COMMAND="true"
	export NUM_BENCHMARKS=1
	export NUM_EXECUTIONS=1
	export SOLUTION_HOME=""
        export SOLUTION_REPORT_DIR=${CLUSTER_SIZE_REPORT_DIR}/${SOLUTION}
	mkdir -p $SOLUTION_REPORT_DIR
	unset FINISH
}

export -f set_no_framework

function setup_phase() {
	if [[ -n "$FRAMEWORK_SETUP" ]]; then
		m_echo "Setting up $SOLUTION: $FRAMEWORK_SETUP"
		bash -c "$FRAMEWORK_SETUP"
	fi
	
	if [[ $ENABLE_BDWATCHDOG == "true" && $BDWATCHDOG_TIMESTAMPING == "true" ]]; then
		export MONGODB_IP=$BDWATCHDOG_MONGODB_IP
		export MONGODB_PORT=$BDWATCHDOG_MONGODB_PORT
		export TESTS_POST_ENDPOINT=$BDWATCHDOG_TESTS_POST_ENDPOINT
		export EXPERIMENTS_POST_ENDPOINT=$BDWATCHDOG_EXPERIMENTS_POST_ENDPOINT

		### MARK start of experiments
		MY_DATE=$(date '+%d-%m-%Y-%H:%M')
		MY_SOLUTION=$(echo $SOLUTION | cut -d"-" -f1)
		EXPERIMENT_NAME="$MY_DATE"_"$MY_SOLUTION"
		${PYTHON_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/timestamping/signal_experiment.py start "$EXPERIMENT_NAME" --username $BDWATCHDOG_USERNAME | \
		${PYTHON_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/mongodb/mongodb_agent.py
	fi	
}

export -f setup_phase

function cleanup_phase() {
	if [[ $ENABLE_BDWATCHDOG == "true" && $BDWATCHDOG_TIMESTAMPING == "true" ]]; then
		### MARK end of experiments
		${PYTHON_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/timestamping/signal_experiment.py end "$EXPERIMENT_NAME" --username $BDWATCHDOG_USERNAME | \
		${PYTHON_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/mongodb/mongodb_agent.py
	fi

	if [[ -n "$FRAMEWORK_CLEANUP" ]]; then
		m_echo "Cleaning up $SOLUTION: $FRAMEWORK_CLEANUP"
		bash -c "$FRAMEWORK_CLEANUP"
	fi
}

export -f cleanup_phase

function write_report() {
	printf " %-5s \t %-25s \t %-20s \t %-10s" $CLUSTER_SIZE $SOLUTION $BENCHMARK $ELAPSED_TIMES >> $REPORT_FILE
	printf "\n" >> $REPORT_FILE

	if [[ $ENABLE_RUNTIME_PLOTS == "true" ]]; then
		m_echo "Generating performance plots"
		if [[ ! -f "$PLOT_DIR" ]]; then
			mkdir -p $PLOT_DIR
		fi
		bash $PLOT_HOME/plot_benchmarks.sh >> $PLOT_DIR/log 2>&1
	fi

	if [[ $ENABLE_RAPL == "true" ]]; then
		m_echo "Generating RAPL plots"
		if [[ ! -f "$RAPL_PLOT_DIR" ]]; then
			mkdir -p $RAPL_PLOT_DIR
		fi
		bash $RAPL_PLOT_HOME/plot_benchmarks.sh >> $RAPL_PLOT_DIR/log 2>&1
	fi

	if [[ $ENABLE_OPROFILE == "true" ]]; then
		m_echo "Generating Oprofile plots"
		if [[ ! -f "$OPROFILE_PLOT_DIR" ]]; then
			mkdir -p $OPROFILE_PLOT_DIR
		fi
		bash $OPROFILE_PLOT_HOME/plot_benchmarks.sh >> $OPROFILE_PLOT_DIR/log 2>&1
	fi
}

export -f write_report

function begin_report() {
	REPORT="$APP_NAME v$APP_VERSION report \n"
	REPORT="$REPORT \n Report directory: \n"
	REPORT="$REPORT \t $REPORT_DIR \n"
	REPORT="$REPORT \n Frameworks directory: \n"
	REPORT="$REPORT \t $BDEV_FRAMEWORKS_DIR \n"
	REPORT="$REPORT \n Configuration: \n"
	if [[ "$NUM_SOLUTIONS" -gt 0 ]]; then
		REPORT="$REPORT \t Frameworks  \t\t\t\t $SOLUTIONS \n"
	fi
	REPORT="$REPORT \t Storage backend  \t\t\t $STORAGE_BACKEND \n"
	if [[ "${STORAGE_BACKEND,,}" == "nfs" ]]; then
		REPORT="$REPORT \t NFS mount point  \t\t\t $NFS_MOUNT_POINT \n"
	fi
	REPORT="$REPORT \t Cluster nodes  \t\t\t $MASTERNODE $SLAVENODES \n"
	REPORT="$REPORT \t Cluster sizes  \t\t\t $CLUSTER_SIZES \n"
	if [[ "$NUM_BENCHMARKS" -gt 0 ]]; then
		REPORT="$REPORT \t Benchmarks  \t\t\t\t $BENCHMARKS \n"
	fi
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
	REPORT="$REPORT \t TMP dir  \t\t\t\t $TMP_DIR \n"
	REPORT="$REPORT \t Local dirs  \t\t\t\t $LOCAL_DIRS \n"
	REPORT="$REPORT \t Disk low-space threshold (%) \t\t $DISK_SPACE_THRESHOLD \n"
	REPORT="$REPORT \t SSH \t\t\t\t\t $SSH_CMD \n"
	REPORT="$REPORT \t JVM \t\t\t\t\t $BDEV_JAVA_HOME \n"
	REPORT="$REPORT \t Python \t\t\t\t $PYTHON_BIN \n"
	if [[ -n $ETHERNET_INTERFACE ]]; then
		REPORT="$REPORT \t Ethernet interface  \t\t\t $ETHERNET_INTERFACE \n"
	else
		REPORT="$REPORT \t Ethernet interface  \t\t\t Not specified \n"
	fi
	if [[ -n $IPOIB_INTERFACE ]]; then
		REPORT="$REPORT \t IPoIB interface  \t\t\t $IPOIB_INTERFACE \n"
	else
		REPORT="$REPORT \t IPoIB interface  \t\t\t Not specified \n"
	fi
	if [[ -n $RDMA_INTERFACE ]]; then
		REPORT="$REPORT \t RDMA interface  \t\t\t $RDMA_INTERFACE \n"
	else
		REPORT="$REPORT \t RDMA interface  \t\t\t Not specified \n"
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
	REPORT="$REPORT \t Spark local dirs  \t\t\t $SPARK_LOCAL_DIRS \n"
	REPORT="$REPORT \t Flink TaskManagers per node   \t\t $FLINK_TASKMANAGERS_PER_NODE \n"
	REPORT="$REPORT \t Flink TaskManager slots   \t\t $FLINK_TASKMANAGER_SLOTS \n"
	REPORT="$REPORT \t Flink TaskManager memory network (MB) \t $FLINK_TASKMANAGER_MEMORY_NETWORK_MAX \n"
	REPORT="$REPORT \t Flink JobManager memory (MB) \t\t $FLINK_JOBMANAGER_MEMORY \n"
	REPORT="$REPORT \t Flink TaskManager memory (MB) \t\t $FLINK_TASKMANAGER_MEMORY \n"
	REPORT="$REPORT \t Flink YARN JobManager memory (MB) \t $FLINK_YARN_JOBMANAGER_MEMORY \n"
	REPORT="$REPORT \t Flink YARN TaskManager memory (MB) \t $FLINK_YARN_TASKMANAGER_MEMORY \n"
	REPORT="$REPORT \t Flink local dirs  \t\t\t $FLINK_LOCAL_DIRS \n"
	REPORT="$REPORT \n Benchmarks: \n"
	
	echo -e "$REPORT" > $REPORT_FILE
	printf " %-5s \t %-25s \t %-20s \t %-10s\n" 'NODES' 'FRAMEWORK' 'BENCHMARK' 'RUNTIME(s)' >> $REPORT_FILE

	if [[ $ENABLE_RUNTIME_PLOTS == "true" ]]; then
		if [[ ! -f "$PLOT_DIR" ]]; then
			mkdir -p $PLOT_DIR
		fi
		bash $PLOT_HOME/plot_legend.sh $PLOT_DIR >> $PLOT_DIR/log 2>&1
	fi

	if [[ $ENABLE_OPROFILE == "true" ]]; then
		if [[ ! -f "$OPROFILE_PLOT_DIR" ]]; then
			mkdir -p $OPROFILE_PLOT_DIR
		fi
		bash $PLOT_HOME/plot_legend.sh $OPROFILE_PLOT_DIR >> $OPROFILE_PLOT_DIR/log 2>&1
	fi

	if [[ $ENABLE_ILO == "true" ]]; then
        	if [[ ! -f "$ILO_DIR" ]]; then
        	        mkdir -p $ILO_DIR
	        fi

        	file=$(basename ${ILO_POWER_SCRIPT_TEMPLATE})
	        ilo_script_content="$(cat ${ILO_POWER_SCRIPT_TEMPLATE})"
        	ilo_script_content=$(echo -e "${ilo_script_content}" | sed "s/adminname/$ILO_USERNAME/g")
	        ilo_script_content=$(echo -e "${ilo_script_content}" | sed "s/password/$ILO_PASSWD/g")
        	echo "${ilo_script_content}" > ${ILO_DIR}/${file}
	        export ILO_POWER_SCRIPT=${ILO_DIR}/${file}
	fi
}

export -f begin_report

function start_benchmark() {
	if [[ -n "$BENCHMARK_SETUP" ]]; then
		m_echo "Setting up ${BENCHMARK^}: $BENCHMARK_SETUP"
		bash -c "$BENCHMARK_SETUP"
	fi

	WAIT_SECONDS=0
	CURRENT_TIME=$(timestamp)
	START_TOTAL_TIME=$(($START_TOTAL_TIME+$CURRENT_TIME))

	if [[ $ENABLE_ILO == "true" ]]; then
		m_echo "Starting ilo monitors"
		bash $ILO_HOME/start_ilo_monitor.sh
		WAIT_SECONDS=$MONITOR_DELAY_SECONDS
	fi
	if [[ $ENABLE_STAT == "true" ]]; then
		m_echo "Starting dool monitors"
		bash $STAT_HOME/start_stat_monitor.sh
		WAIT_SECONDS=$MONITOR_DELAY_SECONDS
	fi
	if [[ $ENABLE_RAPL == "true" ]]; then
		m_echo "Starting rapl monitors"
		bash $RAPL_HOME/start_rapl_monitor.sh
		WAIT_SECONDS=$MONITOR_DELAY_SECONDS
	fi
	if [[ $ENABLE_OPROFILE == "true" ]]; then
		m_echo "Starting oprofile monitors"
		bash $OPROFILE_HOME/start_oprofile_monitor.sh
		WAIT_SECONDS=$MONITOR_DELAY_SECONDS
	fi
    	if [[ $ENABLE_BDWATCHDOG == "true" ]]; then
		m_echo "Starting bdwatchdog monitors"
		if [[ $BDWATCHDOG_ATOP == "true" ]]; then
			m_echo "Starting atop daemons"
			bash $BDWATCHDOG_HOME/start_atop_monitor.sh
		fi
		if [[ $BDWATCHDOG_TURBOSTAT == "true" ]]; then
			m_echo "Starting turbostat daemons"
			bash $BDWATCHDOG_HOME/start_turbostat_monitor.sh
		fi
		if [[ $BDWATCHDOG_NETHOGS == "true" ]]; then
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
			${PYTHON_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/timestamping/signal_test.py start "$EXPERIMENT_NAME" "$BENCHMARK"_"$i" --username $BDWATCHDOG_USERNAME | \
			${PYTHON_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/mongodb/mongodb_agent.py
		fi
	fi

	CURRENT_TIME=`timestamp`
	START_TIME=$(($START_TIME+$CURRENT_TIME))
}

export -f start_benchmark

function end_benchmark() {
	CURRENT_TIME=$(timestamp)
	local code="${1:-${exit_code:-0}}"
	END_TIME=$(($END_TIME+$CURRENT_TIME))

	if [[ $ENABLE_BDWATCHDOG == "true" ]]; then
		if [[ $BDWATCHDOG_TIMESTAMPING == "true" ]]; then
			### MARK end of workload
			${PYTHON_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/timestamping/signal_test.py end "$EXPERIMENT_NAME" "$BENCHMARK"_"$i" --username $BDWATCHDOG_USERNAME | \
			${PYTHON_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/mongodb/mongodb_agent.py
		fi
	fi

	m_echo "Finished ${BENCHMARK^}"

	if [[ $WAIT_SECONDS -gt 0 ]]; then
		m_echo "Waiting $WAIT_SECONDS seconds"
       		sleep $WAIT_SECONDS
    	fi

	if [[ $ENABLE_ILO == "true" ]]; then
		m_echo "Stopping ilo monitors"
		bash $ILO_HOME/stop_ilo_monitor.sh
	fi
	if [[ $ENABLE_OPROFILE == "true" ]]; then
		m_echo "Stopping oprofile monitors"
		bash $OPROFILE_HOME/stop_oprofile_monitor.sh
	fi
	if [[ $ENABLE_RAPL == "true" ]]; then
		m_echo "Stopping rapl monitors"
		bash $RAPL_HOME/stop_rapl_monitor.sh
	fi
	if [[ $ENABLE_STAT == "true" ]]; then
		m_echo "Stopping dool monitors"
		bash $STAT_HOME/stop_stat_monitor.sh
	fi

	if [[ $ENABLE_BDWATCHDOG == "true" ]]; then
		m_echo "Stopping bdwatchdog monitors"
		if [[ $BDWATCHDOG_ATOP == "true" ]]; then
			m_echo "Stopping atop"
			bash $BDWATCHDOG_HOME/stop_atop_monitor.sh
		fi
		if [[ $BDWATCHDOG_TURBOSTAT == "true" ]]; then
			m_echo "Stopping turbostat"
			bash $BDWATCHDOG_HOME/stop_turbostat_monitor.sh
		fi
		if [[ $BDWATCHDOG_NETHOGS == "true" ]]; then
			m_echo "Stopping nethogs"
			bash $BDWATCHDOG_HOME/stop_nethogs_monitor.sh
		fi
	fi

	CURRENT_TIME=$(timestamp)
	END_TOTAL_TIME=$(($END_TOTAL_TIME+$CURRENT_TIME))

	#124 is the standard POSIX code for GNU timeout
	if [[ ${TIMEOUT:-0} -gt 0 && $code -eq 124 ]]; then
		export ELAPSED_TIME="TIMEOUT"
		export ELAPSED_TOTAL_TIME="TIMEOUT"
		m_error "${BENCHMARK^} timeout exceeded (${TIMEOUT} seconds)"
	elif [[ $code -ne 0 ]]; then
		export ELAPSED_TIME="FAILED"
		export ELAPSED_TOTAL_TIME="FAILED"
		m_error "${BENCHMARK^} execution failed (exit code: $code)"
	else
		export ELAPSED_TIME=$(op "($END_TIME - $START_TIME) / 1000")
		export ELAPSED_TOTAL_TIME=$(op "($END_TOTAL_TIME - $START_TOTAL_TIME) / 1000")
	fi

	if [[ -n "$BENCHMARK_CLEANUP" ]]; then
		m_echo "Cleaning up ${BENCHMARK^}: $BENCHMARK_CLEANUP"
		bash -c "$BENCHMARK_CLEANUP"
	fi

	if [[ $ENABLE_OPROFILE == "true" ]]; then
		m_echo "Generating data for Oprofile"
		bash $OPROFILE_PLOT_HOME/plot_oprofile.sh >> $OPROFILELOGDIR/log 2>&1
	fi
	
	if [[ $ENABLE_RAPL == "true" ]]; then
		m_echo "Generating data for RAPL"
		bash $RAPL_PLOT_HOME/plot_rapl.sh >> $RAPLLOGDIR/log 2>&1
	fi
	
	if [[ $ENABLE_STAT == "true" ]]; then
		m_echo "Generating data for dool"
		bash $STAT_PLOT_HOME/plot_stats.sh >> $STATLOGDIR/log 2>&1
	fi
	
	save_elapsed_time
	
	return $code
}

export -f end_benchmark

function run_benchmark() {
	local CMD="$*"
	local exit_code=0
	    
	start_benchmark
	
	if [[ ${TIMEOUT:-0} -gt 0 ]]; then
		m_echo "Running ${BENCHMARK^} (timeout ${TIMEOUT} seconds): $CMD"
		timeout "${TIMEOUT}s" bash -c "set -o pipefail; $CMD 2>&1 | tee -a \"$TMPLOGFILE\""
		exit_code=$?
	else
		m_echo "Running ${BENCHMARK^}: $CMD"
		bash -c "set -o pipefail; $CMD 2>&1 | tee -a \"$TMPLOGFILE\""
		exit_code=$?
	fi

	end_benchmark "$exit_code"

    	return $?
}

export -f run_benchmark

function save_elapsed_time() {
	if [[ "$ELAPSED_TIME" == "FAILED" ]]; then
		FINISH="true"
	elif [[ "$ELAPSED_TIME" == "TIMEOUT" ]]; then
		FINISH="true"
	else
		m_echo "Workload runtime: $ELAPSED_TIME seconds"
		m_echo "Total runtime: $ELAPSED_TOTAL_TIME seconds"
	fi

	echo "$ELAPSED_TIME" > $ELAPSED_TIME_FILE
	ELAPSED_TIMES="$ELAPSED_TIMES $ELAPSED_TIME"
}

export -f save_elapsed_time

function is_nfs() {
    local target_path="$1"

    if [[ -z "$target_path" ]]; then
        return 2
    fi
    
    # findmnt will return 0 if it finds it, and 1 if it doesn't
    findmnt -T "$target_path" -n -t nfs,nfs4 >/dev/null 2>&1
    return $?
}

export -f is_nfs

function require_binary() {
    local behavior="exit"

    if [[ "$1" == "--warn" || "$1" == "-w" ]]; then
        behavior="warn"
        shift
    fi

    local var_name="$1"
    shift # We move the arguments to keep only the list of binaries
    local commands=("$@")
    local bin_path=""
    local found_cmd=""

    # Search for the first existing command (supports fallbacks)
    for cmd in "${commands[@]}"; do
        bin_path=$(which "${cmd}" 2>/dev/null)
        if [[ -n "${bin_path}" ]]; then
            found_cmd="${cmd}"
            break
        fi
    done

    # Error handling if the binary is not found
    if [[ -z "${bin_path}" ]]; then
        if [[ "$behavior" == "warn" ]]; then
            m_warn "Missing optional command. Could not find any of: ${commands[*]}"
            export "${var_name}=null"
            return 1
        else
            m_exit "Missing command. $APP_NAME v$APP_VERSION requires one of: ${commands[*]}"
        fi
    fi

    # Resolve the pure absolute path (untangle module symlinks)
    bin_path=$(readlink -f "${bin_path}")

    # Validate the actual physical file
    if [[ ! -f "${bin_path}" ]]; then
        if [[ "$behavior" == "warn" ]]; then
            m_warn "Missing optional command: ${bin_path} (resolved from ${found_cmd})"
            export "${var_name}=null"
            return 1
        else
            m_exit "Missing command: ${bin_path} (resolved from ${found_cmd})"
        fi
    elif [[ ! -x "${bin_path}" ]]; then
        if [[ "$behavior" == "warn" ]]; then
            m_warn "Optional command is not executable: ${bin_path}"
            export "${var_name}=null"
            return 1
        else
            m_exit "Command is not executable: ${bin_path}"
        fi
    fi

    export "${var_name}=${bin_path}"
    return 0
}

export -f require_binary

check_disk_space() {
    local DISK_MIN_FREE_PERCENT="${DISK_SPACE_THRESHOLD:-5}"
    # Take all arguments passed to the function and replace commas with spaces
    local RAW_DIRS="${*//,/ }"
    local CHECKED_MOUNTS=()

    for dir in $RAW_DIRS; do
        [[ -z "$dir" ]] && continue

        # Si la ruta no existe aún, resolver el ancestro más cercano que sí exista
        local target="$dir"
        while [[ ! -d "$target" && "$target" != "/" && "$target" != "." ]]; do
            target=$(dirname "$target")
        done

        [[ ! -d "$target" ]] && continue

        # Obtener bloques totales ($2), libres ($4) y punto de montaje ($6) en formato POSIX
        local df_info
        df_info=$(df -Pk "$target" 2>/dev/null | awk 'NR==2 {print $2, $4, $6}')
        [[ -z "$df_info" ]] && continue

        local total_kb=$(echo "$df_info" | awk '{print $1}')
        local avail_kb=$(echo "$df_info" | awk '{print $2}')
        local mount_point=$(echo "$df_info" | awk '{print $3}')

        # Deduplicar: omitir si ya se evaluó este mismo punto de montaje
        if [[ " ${CHECKED_MOUNTS[*]} " =~ " ${mount_point} " ]]; then
            continue
        fi
        CHECKED_MOUNTS+=("$mount_point")

        # Evitar división por cero en sistemas virtuales o pseudofs
        (( total_kb == 0 )) && continue

        # Cálculo aritmético nativo de enteros en Bash
        local avail_pct=$(( (avail_kb * 100) / total_kb ))
        local avail_gb=$(( avail_kb / 1024 / 1024 ))

        if (( avail_pct < DISK_MIN_FREE_PERCENT )); then
            m_warn "Low disk space on $HOSTNAME: $mount_point ($target) | ${avail_pct}% free (${avail_gb}GB available)"
        fi
    done
}

export -f check_disk_space

get_interactive_shell() {
    local target="${INTERACTIVE_SHELL:-${SHELL:-/bin/bash}}"
    local resolved
    resolved=$(command -v "$target" 2>/dev/null)

    if [[ -n "$resolved" && -x "$resolved" ]]; then
        echo "$resolved"
    else
        m_warn "Configured shell '$target' not found or not executable. Falling back to /bin/bash"
        echo "/bin/bash"
    fi
}

export -f get_interactive_shell

check_ssh_connectivity() {
    local test_node="$1"
    local ssh_output
    local exit_code

    # Execute the null command ':' or 'true' by capturing the error output
    m_echo "Checking SSH connectivity to $test_node"
    ssh_output=$($SSH_CMD "$test_node" ":" 2>&1)
    exit_code=$?

    if [ $exit_code -ne 0 ]; then
    	m_error "SSH pre-flight check failed on node: $test_node"
        m_error "Command executed: $SSH_CMD $test_node \":\""
        m_error "Exit code: $exit_code" >&2
        m_error "Details: $ssh_output" >&2
        m_exit "Please check the hostfile, BDEV_SSH_OPTS in system-conf.sh and verify that passwordless SSH is properly configured"
    fi
}

export -f check_ssh_connectivity

function sum() {
    SUM=0
    local -a values=($*)
    if [[ ${#values[@]} -gt 0 ]]; then
        local old_ifs="$IFS"
        IFS='+'
        local expr="${values[*]}"
        IFS="$old_ifs"
        SUM=$(op "0 + $expr")
    fi
    echo "$SUM"
}

export -f sum

function median() {
    local -a values=($*)
    COUNT=${#values[@]}
    if [[ $COUNT -eq 0 ]]; then
        unset MIDDLE
    else
        MIDDLE=$((1 + COUNT / 2))
        if [[ $COUNT -eq 1 ]]; then
            MEDIAN="${values[0]}"
        else
            local -a sorted
            mapfile -t sorted < <(printf '%s\n' "${values[@]}" | LC_ALL=C sort -n)
            MEDIAN="${sorted[MIDDLE-1]}"
        fi
    fi
}

export -f median

function avg() {
    SUM=0
    COUNT=0
    local -a valid=()
    local val
    for val in $*; do
        if [[ "$val" != "FAILED" && "$val" != "TIMEOUT" ]]; then
            valid+=("$val")
        fi
    done

    COUNT=${#valid[@]}
    if [[ $COUNT -eq 0 ]]; then
        unset AVG
        return 0
    fi

    local old_ifs="$IFS"
    IFS='+'
    local expr="${valid[*]}"
    IFS="$old_ifs"

    local is_zero
    read -r SUM is_zero AVG < <(bc <<EOF
scale=4
s = 0 + $expr
print s, " ", (s == 0), " "
if (s != 0) {
    scale=2
    print s / $COUNT
}
EOF
    )

    if [[ "$is_zero" -eq 1 ]]; then
        unset AVG
    fi
}

export -f avg

function maxmin() {
    unset MAX
    unset MIN
    local -a valid=()
    local val
    for val in $*; do
        if [[ "$val" != "FAILED" && "$val" != "TIMEOUT" ]]; then
            valid+=("$val")
        fi
    done

    local count=${#valid[@]}
    if [[ $count -eq 0 ]]; then
        return 0
    fi

    if [[ $count -eq 1 ]]; then
        MAX="${valid[0]}"
        MIN="${valid[0]}"
        return 0
    fi

    local -a sorted
    mapfile -t sorted < <(printf '%s\n' "${valid[@]}" | LC_ALL=C sort -n)
    MIN="${sorted[0]}"
    MAX="${sorted[count-1]}"
}

export -f maxmin
