#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_WORDCOUNT

run_benchmark "$FLINK_HOME/bin/flink run \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.ScalaWordCount $FLINK_BENCH_JAR \
	$INPUT_WORDCOUNT $OUTPUT_WORDCOUNT $EXAMPLES_DATA_FORMAT"

if [ $(cat $TMPLOGFILE | grep -i -E "Job execution switched to status FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
