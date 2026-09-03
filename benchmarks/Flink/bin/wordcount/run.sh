#!/bin/bash

storage_rm -R ${OUTPUT_WORDCOUNT}

run_benchmark "$FLINK_HOME/bin/flink \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.dataset.ScalaWordCount $FLINK_BENCH_JAR \
	$INPUT_WORDCOUNT $OUTPUT_WORDCOUNT $EXAMPLES_DATA_FORMAT"
