#!/bin/sh

${HDFS_CMD} ${RMR} $OUTPUT_SORT

run_benchmark "$FLINK_HOME/bin/flink run \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.ScalaSort $FLINK_BENCH_JAR \
	$INPUT_SORT $OUTPUT_SORT $EXAMPLES_DATA_FORMAT"

if [ $(cat $TMPLOGFILE | grep -i -E "Job execution switched to status FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
