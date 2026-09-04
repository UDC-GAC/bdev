#!/bin/bash

m_start_message

m_echo "Initializing"

# Load hostfile
. $BDEV_BIN_DIR/load-hostfile.sh

# Check SSH connectivity (fail fast)
check_ssh_connectivity "$MASTERNODE"

. $CLEANUP_PROCESS_SCRIPT

begin_report
