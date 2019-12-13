#!/bin/sh

if [[ "$SGE_ENV" == "true" ]]
then
	if [[ ! -z $SOL_SGE_DAEMONS_DIR ]]
	then
		m_echo "Copying daemons from $SOL_SGE_DAEMONS_DIR"
		cp $SOL_SGE_DAEMONS_DIR/* $SOL_SBIN_DIR
	else
		m_echo "No daemons directory to copy"
	fi
else
	if [[ ! -z $SOL_STD_DAEMONS_DIR ]]
	then
		m_echo "Copying daemons from $SOL_STD_DAEMONS_DIR"
		cp $SOL_STD_DAEMONS_DIR/* $SOL_SBIN_DIR
	else
		m_echo "No daemons directory to copy"
	fi
fi

