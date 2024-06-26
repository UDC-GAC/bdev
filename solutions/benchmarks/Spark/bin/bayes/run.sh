#!/bin/sh

${HDFS_CMD} ${RMR} $OUTPUT_BAYES

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.gac.sparkbench.ScalaMLlibSparseNaiveBayes ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	${INPUT_BAYES} ${OUTPUT_BAYES}/model"

if [ $(cat $TMPLOGFILE | grep -i -E "final status: FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
