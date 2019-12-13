#!/bin/sh

if [[ -z $METHOD_COMMAND ]]
then

	m_echo "Entering interactive mode"

	start_benchmark
	$SHELL -i 2>&1 | tee $TMPLOGFILE
	end_benchmark

	m_echo "Leaving interactive mode"
else
	m_echo "Running $METHOD_COMMAND"
	run_benchmark $METHOD_COMMAND
fi
