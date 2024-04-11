#!/bin/sh

${HDFS_CMD} ${RMR} $OUTPUT_GREP

run_benchmark "$FLINK_HOME/bin/flink run \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.ScalaGrep $FLINK_BENCH_JAR \
	$INPUT_GREP $OUTPUT_GREP $GREP_REGEX $EXAMPLES_DATA_FORMAT"

if [ $(cat $TMPLOGFILE | grep -i -E "Job execution switched to status FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
