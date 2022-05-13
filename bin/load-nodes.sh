#!/bin/sh

if [[ -f "$HOSTFILE" ]]
then
	export COMPUTE_NODES=`cut -d " " -f 1 $HOSTFILE`
elif [[ -z "$COMPUTE_NODES" ]]
then
	m_exit "Missing HOSTFILE"
fi

export IP_COMMAND=`which ip`
export RESOLVEIP_COMMAND=`which getent`

export NODE_FILE=$REPORT_DIR/hostfile
export COMPUTE_NODES=`get_nodes_by_hostname $NODE_FILE $COMPUTE_NODES`
if [[ -z "${COMPUTE_NODES}" ]]; then
	m_exit "Nodes: Revise network settings"
fi
m_echo "Nodes: "$COMPUTE_NODES

if [[ ! -z $ETH_INTERFACE ]]; then
	export NODE_FILE_ETH=$REPORT_DIR/hostfile.eth
	export ETH_COMPUTE_NODES=`get_nodes_by_interface $NODE_FILE_ETH $ETH_INTERFACE $COMPUTE_NODES`
	if [[ -z "${ETH_COMPUTE_NODES}" ]]; then
		export ETH_COMPUTE_NODES=""
		rm $NODE_FILE_ETH >& /dev/null
		m_warn "ETH ($ETH_INTERFACE): interface will be ignored"
	else
		m_echo "ETH ($ETH_INTERFACE): "$ETH_COMPUTE_NODES
	fi
fi

if [[ ! -z $IPOIB_INTERFACE ]]; then
	export NODE_FILE_IPOIB=$REPORT_DIR/hostfile.ipoib
       	export IPOIB_COMPUTE_NODES=`get_nodes_by_interface $NODE_FILE_IPOIB $IPOIB_INTERFACE $COMPUTE_NODES`
	if [[ -z "${IPOIB_COMPUTE_NODES}" ]]; then
		export IPOIB_COMPUTE_NODES=""
		rm $NODE_FILE_IPOIB >& /dev/null
		m_warn "IPoIB ($IPOIB_INTERFACE): interface will be ignored"
	else
		m_echo "IPoIB ($IPOIB_INTERFACE): "$IPOIB_COMPUTE_NODES
	fi
fi

if [[ ! -n ${ETH_COMPUTE_NODES} ]] && [[ ! -n "${IPOIB_COMPUTE_NODES}" ]]; then
	m_warn "No valid interface has been configured. Using default configuration"
fi

load_nodes $COMPUTE_NODES
