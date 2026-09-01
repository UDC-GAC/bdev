#!/bin/bash

storage_rm -R ${OUTPUT_PAGERANK}

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.gac.sparkbench.${SPARK_API}.ScalaPageRank ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	${INPUT_PAGERANK}/edges ${OUTPUT_PAGERANK} ${PAGERANK_PAGES} ${PAGERANK_MAX_ITERATIONS}"
