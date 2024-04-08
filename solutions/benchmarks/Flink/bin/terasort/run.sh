#!/bin/sh

${HDFS_CMD} ${RMR} $OUTPUT_TERASORT

run_benchmark "$FLINK_HOME/bin/flink run \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.ScalaTeraSort $FLINK_BENCH_JAR \
	$INPUT_TERASORT $OUTPUT_TERASORT"

if [ $(cat $TMPLOGFILE | grep -i -E "Job execution switched to status FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
