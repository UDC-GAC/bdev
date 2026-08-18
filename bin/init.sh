#!/bin/sh

m_start_message

m_echo "Initializing"

# Load nodes and IPs
. $BDEV_BIN_DIR/load-nodes.sh

# Load storage backend functions
. $COMMON_SRC_DIR/lib/storage_backend.sh

. $CLEAN_DAEMONS_SCRIPT

begin_report
