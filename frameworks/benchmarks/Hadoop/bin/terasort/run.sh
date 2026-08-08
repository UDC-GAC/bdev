#!/bin/sh

${HDFS_CMD} ${RMR} $OUTPUT_TERASORT

run_benchmark "$HADOOP_EXECUTABLE jar $HADOOP_EXAMPLES_JAR terasort \
 	-D $CONFIG_REDUCER_NUMBER=$REDUCERS_NUMBER $INPUT_TERASORT $OUTPUT_TERASORT"

if [ $(cat $TMPLOGFILE | grep -i -E "job failed|FinalApplicationStatus=FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
