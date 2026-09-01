#!/bin/bash

storage_rm -R ${OUTPUT_TERASORT}

run_benchmark "$FLINK_HOME/bin/flink \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.dataset.ScalaTeraSort $FLINK_BENCH_JAR \
	$INPUT_TERASORT $OUTPUT_TERASORT"
