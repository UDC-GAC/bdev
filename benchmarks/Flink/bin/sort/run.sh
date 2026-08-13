#!/bin/sh

storage_rm -R ${OUTPUT_SORT}

run_benchmark "$FLINK_HOME/bin/flink \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.ScalaSort $FLINK_BENCH_JAR \
	$INPUT_SORT $OUTPUT_SORT $EXAMPLES_DATA_FORMAT"
