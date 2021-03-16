#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_PAGERANK

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.gac.sparkbench.dataset.ScalaNaivePageRank ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	${INPUT_PAGERANK}/edges ${OUTPUT_PAGERANK} ${PAGERANK_PAGES} ${PAGERANK_MAX_ITERATIONS}"

if [ $(cat $TMPLOGFILE | grep -i -E "final status: FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
