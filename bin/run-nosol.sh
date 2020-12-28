#!/bin/bash

#Set network configuration
set_network_configuration

. ${COMMON_BENCH_DIR}/conf/configure.sh
. ${COMMON_BENCH_DIR}/bin/prepare.sh

start_solution

if [[ $ENABLE_BDWATCHDOG == "true" ]]; then
	if [[ $BDWATCHDOG_TIMESTAMPING == "true" ]]; then
		export MONGODB_IP=$BDWATCHDOG_MONGODB_IP
		export MONGODB_PORT=$BDWATCHDOG_MONGODB_PORT
		export TESTS_POST_ENDPOINT=$BDWATCHDOG_TESTS_POST_ENDPOINT
		export EXPERIMENTS_POST_ENDPOINT=$BDWATCHDOG_EXPERIMENTS_POST_ENDPOINT

	### MARK start of experiments
		MY_DATE=`date '+%d-%m-%Y-%H:%M'`
		MY_SOLUTION=`echo $SOLUTION | cut -d"-" -f1`
		EXPERIMENT_NAME="$MY_DATE"_"$MY_SOLUTION"
		${PYTHON3_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/timestamping/signal_experiment.py start "$EXPERIMENT_NAME" --username $BDWATCHDOG_USERNAME | \
		${PYTHON3_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/mongodb/mongodb_agent.py
	fi
fi

#For each benchmark
for BENCHMARK in $BENCHMARKS
do
	export BENCHMARK
	unset ELAPSED_TIMES
	for i in `seq 1 $NUM_EXECUTIONS`
	do
		. $METHOD_BIN_DIR/bench-env.sh
		# Starting workload
		m_echo "Running ${BENCHMARK}, reporting to ${BENCHMARK_OUTPUT_DIR}"

                if [[ $BENCHMARK_WAIT_SECONDS -gt 0 ]]
                then
                        m_echo "Waiting $BENCHMARK_WAIT_SECONDS seconds"
                        sleep $BENCHMARK_WAIT_SECONDS
                fi

		if [[ -f ${SOL_BENCH_DIR}/bin/${BENCHMARK}/run.sh ]]
		then
			. ${SOL_BENCH_DIR}/bin/${BENCHMARK}/run.sh
		elif [[ -f ${COMMON_BENCH_DIR}/bin/${BENCHMARK}/run.sh ]]
		then
			. ${COMMON_BENCH_DIR}/bin/${BENCHMARK}/run.sh
		else
			m_echo "${BENCHMARK^} benchmark is not currently supported by ${SOLUTION}"
			break
		fi

		save_elapsed_time

		if [[ $FINISH == "true" ]]
		then
			break
		fi
	done
	write_report
	if [[ $FINISH == "true" ]]
	then
		break
	fi
done

if [[ $ENABLE_BDWATCHDOG == "true" ]]; then
	if [[ $BDWATCHDOG_TIMESTAMPING == "true" ]]; then
	### MARK end of experiments
		${PYTHON3_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/timestamping/signal_experiment.py end "$EXPERIMENT_NAME" --username $BDWATCHDOG_USERNAME | \
		${PYTHON3_BIN} $BDWATCHDOG_TIMESTAMPING_SERVICE/mongodb/mongodb_agent.py
	fi
fi

end_solution

