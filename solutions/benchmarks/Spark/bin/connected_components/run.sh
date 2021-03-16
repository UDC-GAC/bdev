#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_CC

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.gac.sparkbench.rdd.ScalaGraphXConnectedComponents ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	${INPUT_CC}/edges ${OUTPUT_CC} ${CC_PAGES} ${CC_MAX_ITERATIONS}"

if [ $(cat $TMPLOGFILE | grep -i -E "final status: FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
