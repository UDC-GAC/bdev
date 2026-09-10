#!/bin/bash

#Set network configuration
configure_network

#Init and load configuration parameters
. ${BDEV_BIN_DIR}/conf-params.sh

#Configure framework
m_echo "Configuring $FRAMEWORK"
. ${BDEV_BIN_DIR}/setup-framework.sh

#Start framework
m_echo "Starting $FRAMEWORK"
. ${FRAMEWORK_DIR}/bin/start.sh

#Generate input datasets
. ${COMMON_BENCH_DIR}/bin/prepare.sh
if [[ -f ${FRAMEWORK_BENCH_DIR}/bin/prepare.sh ]]; then
	. ${FRAMEWORK_BENCH_DIR}/bin/prepare.sh
fi

setup_phase

#For each benchmark
for BENCHMARK in $BENCHMARKS; do
	export BENCHMARK
	unset RUNTIMES
	i=1

	while [[ "$i" -le "$NUM_EXECUTIONS" ]]; do
		. ${BDEV_BIN_DIR}/bench-env.sh $i
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

		if [[ -f ${FRAMEWORK_BENCH_DIR}/bin/${BENCHMARK}/run.sh ]]; then
			. ${FRAMEWORK_BENCH_DIR}/bin/${BENCHMARK}/run.sh
		elif [[ -f ${COMMON_BENCH_DIR}/bin/${BENCHMARK}/run.sh ]]; then
			. ${COMMON_BENCH_DIR}/bin/${BENCHMARK}/run.sh
		else
			m_warn "${BENCHMARK^} benchmark is not currently supported by ${FRAMEWORK}"
			break
		fi

		if [[ $BENCHMARK_FAILED == "true" ]]; then
			break
		fi
	done

	write_report
done

cleanup_phase

#Stop framework
m_echo "Stopping $FRAMEWORK"
. ${FRAMEWORK_DIR}/bin/stop.sh
