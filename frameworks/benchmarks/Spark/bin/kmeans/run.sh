#!/bin/sh

${HDFS_CMD} ${RMR} $OUTPUT_KMEANS

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.gac.sparkbench.ScalaMLlibDenseKMeans ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	--input ${INPUT_KMEANS}/samples --centers ${INPUT_KMEANS}/cluster --output ${OUTPUT_KMEANS} \
	--numIterations ${KMEANS_MAX_ITERATIONS} --convergenceDelta ${KMEANS_CONVERGENCE_DELTA}"

if [ $(cat $TMPLOGFILE | grep -i -E "final status: FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
