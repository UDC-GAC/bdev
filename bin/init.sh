#!/bin/bash

m_start_message

m_echo "Initializing"

# Load nodes and IPs
. $BDEV_BIN_DIR/load-nodes.sh

. $CLEAN_DAEMONS_SCRIPT

begin_report
