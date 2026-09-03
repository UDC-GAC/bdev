#!/bin/bash

#Set network configuration
configure_network

#Init and load configuration parameters
. ${BDEV_BIN_DIR}/conf-params.sh

#Generate input datasets
. ${COMMON_BENCH_DIR}/bin/prepare.sh

export BENCHMARK=command
unset ELAPSED_TIMES

setup_phase

. $BDEV_BIN_DIR/bench-env.sh

# Starting workload
m_echo "Running ${BENCHMARK^}, logging to ${BENCHMARK_OUTPUT_DIR}"

START_TOTAL_TIME=0
END_TOTAL_TIME=0
START_TIME=0
END_TIME=0

if [[ $BENCHMARK_WAIT_SECONDS -gt 0 ]]; then
	m_echo "Waiting $BENCHMARK_WAIT_SECONDS seconds"
	sleep $BENCHMARK_WAIT_SECONDS
fi

# Run command benchmark
. ${COMMON_BENCH_DIR}/bin/${BENCHMARK}/run.sh

save_elapsed_time

write_report

cleanup_phase
