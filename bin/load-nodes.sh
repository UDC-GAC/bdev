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
m_echo "Nodes: "$COMPUTE_NODES

export NODE_FILE=$REPORT_DIR/hostfile
export IP_COMPUTE_NODES=`get_nodes_by_name $NODE_FILE $COMPUTE_NODES`
m_echo "IP nodes: "$IP_COMPUTE_NODES

if [[ ! -z $GBE_INTERFACE ]]
then
	export NODE_FILE_GBE=$REPORT_DIR/hostfile.gbe
	export GBE_COMPUTE_NODES=`get_nodes_by_interface $NODE_FILE_GBE $GBE_INTERFACE $COMPUTE_NODES`
	m_echo "GbE nodes: "$GBE_COMPUTE_NODES
fi

if [[ ! -z $IPOIB_INTERFACE ]]
then
	export NODE_FILE_IPOIB=$REPORT_DIR/hostfile.ipoib
       	export IPOIB_COMPUTE_NODES=`get_nodes_by_interface $NODE_FILE_IPOIB $IPOIB_INTERFACE $COMPUTE_NODES`
	m_echo "IPoIB nodes: "$IPOIB_COMPUTE_NODES
fi

load_nodes $COMPUTE_NODES

if [[ $ILO_MASTER == "localhost" ]]
then
        export ILO_MASTER=$MASTERNODE
fi

