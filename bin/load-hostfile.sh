#!/bin/bash

if [[ -n "${BDEV_HOSTFILE:-}" ]]; then
	if [[ ! -f "$BDEV_HOSTFILE" ]]; then
		m_exit "Missing BDEV_HOSTFILE: $BDEV_HOSTFILE"
	fi
	
	export COMPUTE_NODES=$(awk '{print $1}' "$BDEV_HOSTFILE")
elif [[ "$SLURM_ENV" == "true" ]]; then
	export COMPUTE_NODES=$(scontrol show hostname $SLURM_JOB_NODELIST)
else
	m_exit "BDEV_HOSTFILE is not defined or is empty"
fi

export HOSFTILE_DEFAULT=$REPORT_DIR/hostfile
export COMPUTE_NODES=$(get_nodes_by_hostname $HOSFTILE_DEFAULT $COMPUTE_NODES)

if [[ -z "${COMPUTE_NODES}" ]]; then
	m_exit "There were errors processing the hostfile: $BDEV_HOSTFILE. Revise network settings"
fi

export NUM_NODES=$(echo "$COMPUTE_NODES" | wc -w)
m_echo "Nodes ($NUM_NODES): $COMPUTE_NODES"

if [[ ! -z "${ETHERNET_INTERFACE}" ]]; then
	export HOSFTILE_ETHERNET=$REPORT_DIR/hostfile.ethernet
	export ETHERNET_COMPUTE_NODES=$(get_nodes_by_interface $HOSFTILE_ETHERNET $ETHERNET_INTERFACE $COMPUTE_NODES)
	
	if [[ -z "${ETHERNET_COMPUTE_NODES}" ]]; then
		export ETHERNET_COMPUTE_NODES=""
		rm $HOSFTILE_ETHERNET >& /dev/null
		m_warn "Ethernet ($ETHERNET_INTERFACE): interface will be ignored"
	else
		m_echo "Ethernet ($ETHERNET_INTERFACE): $ETHERNET_COMPUTE_NODES"
	fi
fi

if [[ ! -z "${IPOIB_INTERFACE}" ]]; then
	export HOSFTILE_IPOIB=$REPORT_DIR/hostfile.ipoib
       	export IPOIB_COMPUTE_NODES=$(get_nodes_by_interface $HOSFTILE_IPOIB $IPOIB_INTERFACE $COMPUTE_NODES)
	
	if [[ -z "${IPOIB_COMPUTE_NODES}" ]]; then
		export IPOIB_COMPUTE_NODES=""
		rm $HOSFTILE_IPOIB >& /dev/null
		m_warn "IPoIB ($IPOIB_INTERFACE): interface will be ignored"
	else
		m_echo "IPoIB ($IPOIB_INTERFACE): $IPOIB_COMPUTE_NODES"
	fi
fi

if [[ ! -n "${ETHERNET_COMPUTE_NODES}" && ! -n "${IPOIB_COMPUTE_NODES}" ]]; then
	m_warn "No valid interface has been configured. Using default configuration"
fi

# Load initial nodes
configure_nodes $COMPUTE_NODES

# Replace MAX in CLUSTER_SIZES (if needed)
export CLUSTER_SIZES=$(sed "s/MAX/$MAX_NODES/gI" <<< "$CLUSTER_SIZES")
