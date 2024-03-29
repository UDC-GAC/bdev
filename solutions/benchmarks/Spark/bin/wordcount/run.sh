#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_WORDCOUNT

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.gac.sparkbench.ScalaWordCount ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	$INPUT_WORDCOUNT $OUTPUT_WORDCOUNT $EXAMPLES_DATA_FORMAT"

if [ $(cat $TMPLOGFILE | grep -i -E "final status: FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
