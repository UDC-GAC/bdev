#!/bin/sh

if [[ -z $COMMAND ]]
then
	m_echo "Entering interactive mode"

	start_benchmark
	$SHELL -i 2>&1 | tee $TMPLOGFILE
	end_benchmark

	m_echo "Leaving interactive mode"
else
	if [[ -d $COMMAND ]]; then
		COMMANDS=`ls -d $COMMAND/*`

		for CMD in $COMMANDS
		do
			m_echo "Running $CMD"
			run_benchmark $CMD
		done
	else
		m_echo "Running $COMMAND"
		run_benchmark $COMMAND
	fi
fi
