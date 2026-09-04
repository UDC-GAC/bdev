#!/bin/bash

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
    m_exit "Nodes extracted from $nodes_source is empty. Please verify your configuration."
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
	export HOSFTILE_ETHERNET="$REPORT_DIR/hostfile.ethernet"
	
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
	export HOSFTILE_IPOIB="$REPORT_DIR/hostfile.ipoib"
	
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
	m_warn "No valid network interface hconfigured. Using default configuration"
fi

# Load initial nodes
configure_nodes $COMPUTE_NODES

# Replace MAX in CLUSTER_SIZES (if needed)
export CLUSTER_SIZES=$(sed "s/MAX/$MAX_NODES/gI" <<< "$CLUSTER_SIZES")
