#!/bin/bash

m_start_message

m_echo "Initializing"

# Load hostfile
. $BDEV_BIN_DIR/load-hostfile.sh

. $CLEANUP_PROCESS_SCRIPT

begin_report
