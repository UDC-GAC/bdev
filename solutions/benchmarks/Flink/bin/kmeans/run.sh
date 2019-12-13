#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_KMEANS

run_benchmark "$FLINK_HOME/bin/flink run \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.ScalaNaiveDenseKMeans $FLINK_BENCH_JAR \
	--input ${INPUT_KMEANS}/samples --centers ${INPUT_KMEANS}/cluster --output ${OUTPUT_KMEANS} \
	--numIterations ${KMEANS_MAX_ITERATIONS} --convergenceDelta ${KMEANS_CONVERGENCE_DELTA}"

if [ $(cat $TMPLOGFILE | grep -i -E "Job execution switched to status FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
