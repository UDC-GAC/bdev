#!/bin/bash

if [[ ! -z $SOL_DAEMONS_DIR ]]; then
	m_echo "Copying daemons from $SOL_DAEMONS_DIR"
	cp $SOL_DAEMONS_DIR/* $SOL_SBIN_DIR 2> /dev/null
else
	m_echo "No daemons directory to copy"
fi
