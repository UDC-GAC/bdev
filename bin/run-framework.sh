#!/bin/bash

#Set network configuration
configure_network

# Init and load configuration parameters
. ${BDEV_BIN_DIR}/conf-params.sh

#Read solution environment
m_echo "Reading environment: ${SOLUTION_DIR}/etc/env.sh"
. ${SOLUTION_DIR}/etc/env.sh

#Init framework
m_echo "Initiliazing $SOLUTION"
. ${INIT_SOL_SCRIPT}
. ${COMMON_BENCH_DIR}/conf/configure.sh

#Start framework
m_echo "Starting $SOLUTION"
. ${SOLUTION_DIR}/bin/start.sh

#Configure benchmarks
m_echo "Configuring benchmarks"
. ${SOL_BENCH_DIR}/conf/configure.sh

#Generate input datasets
. ${COMMON_BENCH_DIR}/bin/prepare.sh
if [[ -f ${SOL_BENCH_DIR}/bin/prepare.sh ]]; then
	. ${SOL_BENCH_DIR}/bin/prepare.sh
fi

setup_phase

#For each benchmark
for BENCHMARK in $BENCHMARKS
do
	export BENCHMARK
	unset ELAPSED_TIMES
	i=1

	while [[ "$i" -le "$NUM_EXECUTIONS" ]]
	do
		. $BDEV_BIN_DIR/bench-env.sh $i
		# Starting workload
		m_echo "Running ${BENCHMARK^}, logging to ${BENCHMARK_OUTPUT_DIR}"

		START_TOTAL_TIME=0
		END_TOTAL_TIME=0
		START_TIME=0
		END_TIME=0
		i=$((i + 1))

		if [[ $BENCHMARK_WAIT_SECONDS -gt 0 ]]; then
			m_echo "Waiting $BENCHMARK_WAIT_SECONDS seconds"
			sleep $BENCHMARK_WAIT_SECONDS
		fi

		if [[ -f ${SOL_BENCH_DIR}/bin/${BENCHMARK}/run.sh ]]; then
			. ${SOL_BENCH_DIR}/bin/${BENCHMARK}/run.sh
		elif [[ -f ${COMMON_BENCH_DIR}/bin/${BENCHMARK}/run.sh ]]; then
			. ${COMMON_BENCH_DIR}/bin/${BENCHMARK}/run.sh
		else
			m_warn "${BENCHMARK^} benchmark is not currently supported by ${SOLUTION}"
			break
		fi

		save_elapsed_time

		if [[ $FINISH == "true" ]]; then
			break
		fi
	done

	write_report
	
	if [[ $FINISH == "true" ]]; then
		break
	fi
done

cleanup_phase

#Finish framework
m_echo "Finishing $SOLUTION"
. $SOLUTION_DIR/bin/finish.sh
