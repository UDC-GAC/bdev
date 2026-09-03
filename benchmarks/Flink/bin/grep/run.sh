#!/bin/bash

storage_rm -R ${OUTPUT_GREP}

run_benchmark "$FLINK_HOME/bin/flink \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.dataset.ScalaGrep $FLINK_BENCH_JAR \
	$INPUT_GREP $OUTPUT_GREP $GREP_REGEX $EXAMPLES_DATA_FORMAT"
