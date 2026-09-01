#!/bin/bash

storage_rm -R ${OUTPUT_CC}

run_benchmark "$FLINK_HOME/bin/flink \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.dataset.ScalaConnectedComponents $FLINK_BENCH_JAR \
	${INPUT_CC}/edges ${OUTPUT_CC} ${CC_PAGES} ${CC_MAX_ITERATIONS}"
