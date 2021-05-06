#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_BAYES

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.gac.sparkbench.dataset.ScalaMLlibSparseNaiveBayes ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	${INPUT_BAYES} ${OUTPUT_BAYES}/model"

if [ $(cat $TMPLOGFILE | grep -i -E "final status: FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
