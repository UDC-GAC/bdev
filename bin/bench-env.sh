#!/bin/sh

export BENCHMARK_OUTPUT_DIR=$SOLUTION_REPORT_DIR/${BENCHMARK}_${i}
mkdir -p $BENCHMARK_OUTPUT_DIR
export TMPLOGFILE=$BENCHMARK_OUTPUT_DIR/output
export POWERLOGDIR=$BENCHMARK_OUTPUT_DIR/pow_records
export STATLOGDIR=$BENCHMARK_OUTPUT_DIR/stat_records
export RAPLLOGDIR=$BENCHMARK_OUTPUT_DIR/rapl_records
export OPROFILELOGDIR=$BENCHMARK_OUTPUT_DIR/oprofile_records
export BDW_LOG_DIR=$BENCHMARK_OUTPUT_DIR/bdwatchdog
export ELAPSED_TIME_FILE=$BENCHMARK_OUTPUT_DIR/runtime
unset ELAPSED_TIME
unset READ_SIZE

case "$BENCHMARK" in 

	'testdfsio')
		export TIMEOUT=$TESTDFSIO_TIMEOUT
	;;

	'wordcount')
		export TIMEOUT=$WORDCOUNT_TIMEOUT
	;;

	'sort')
		export TIMEOUT=$SORT_TIMEOUT
	;;

	'terasort')
		export TIMEOUT=$TERASORT_TIMEOUT
	;;

	'grep')
		export TIMEOUT=$GREP_TIMEOUT
	;;

	'pagerank')
		export TIMEOUT=$PAGERANK_TIMEOUT
	;;

	'connected_components')
		export TIMEOUT=$CC_TIMEOUT
	;;

	'bayes')
		export TIMEOUT=$BAYES_TIMEOUT
	;;

	'kmeans')
		export TIMEOUT=$KMEANS_TIMEOUT
	;;

	'aggregation')
		export TIMEOUT=$AGGREGATION_TIMEOUT
	;;

	'join')
		export TIMEOUT=$JOIN_TIMEOUT
	;;

	'scan')
		export TIMEOUT=$SCAN_TIMEOUT
	;;

	'tpcx_hs')
		export TIMEOUT=$TPCX_HS_TIMEOUT
	;;

	'command')
		export TIMEOUT=$COMMAND_TIMEOUT
	;;

esac

if [[ -z $TIMEOUT ]]
then
	TIMEOUT=$DEFAULT_TIMEOUT
fi

if [[ -n "$TIMEOUT" && "$TIMEOUT" != "0" ]]
then
	m_echo "Timeout set to $TIMEOUT seconds"
fi
