#!/bin/sh

${HDFS_CMD} ${RMR} $OUTPUT_TERASORT

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.gac.sparkbench.ScalaTeraSort ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	$INPUT_TERASORT $OUTPUT_TERASORT"

if [ $(cat $TMPLOGFILE | grep -i -E "final status: FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
