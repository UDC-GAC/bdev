#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_CC

run_benchmark "$FLINK_HOME/bin/flink run \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.ScalaGellyConnectedComponents $FLINK_BENCH_JAR \
	${INPUT_CC}/edges ${OUTPUT_CC} ${CC_PAGES} ${CC_MAX_ITERATIONS}"

if [ $(cat $TMPLOGFILE | grep -i -E "Job execution switched to status FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
