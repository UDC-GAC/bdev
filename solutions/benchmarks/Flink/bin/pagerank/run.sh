#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_PAGERANK

run_benchmark "$FLINK_HOME/bin/flink run \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.ScalaPageRank $FLINK_BENCH_JAR \
	${INPUT_PAGERANK}/edges ${OUTPUT_PAGERANK} ${PAGERANK_PAGES} ${PAGERANK_MAX_ITERATIONS}"

if [ $(cat $TMPLOGFILE | grep -i -E "Job execution switched to status FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
