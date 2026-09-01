#!/bin/bash

storage_rm -R ${OUTPUT_PAGERANK}

run_benchmark "$FLINK_HOME/bin/flink \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.dataset.ScalaPageRank $FLINK_BENCH_JAR \
	${INPUT_PAGERANK}/edges ${OUTPUT_PAGERANK} ${PAGERANK_PAGES} ${PAGERANK_MAX_ITERATIONS}"
