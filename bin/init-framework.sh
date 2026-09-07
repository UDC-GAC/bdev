#!/bin/bash

#Loading framework environment
m_echo "Loading environment: ${SOLUTION_DIR}/etc/env.sh"
. ${SOLUTION_DIR}/etc/env.sh

#Generate framework configuration
. "${SOLUTION_DIR}/bin/gen-config.sh"

m_echo "Master: $MASTERNODE"
m_echo "Workers:"
while read -r NODE; do
    m_echo $'\t'"$NODE"
done < "$WORKERSFILE"

#Common configuration for benchmarks
. ${COMMON_BENCH_DIR}/conf/configure.sh

#Configure benchmarks for this framework
m_echo "Configuring benchmarks"
if [[ -f ${SOLUTION_BENCH_DIR}/conf/configure.sh ]]; then
	. ${SOLUTION_BENCH_DIR}/conf/configure.sh
fi
