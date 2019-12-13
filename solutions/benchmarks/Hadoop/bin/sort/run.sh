#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_SORT

run_benchmark "$HADOOP_EXECUTABLE jar $HADOOP_EXAMPLES_JAR sort \
    -outKey org.apache.hadoop.io.Text \
    -outValue org.apache.hadoop.io.Text \
    -inFormat ${EXAMPLES_INPUT_FORMAT} \
    -outFormat ${EXAMPLES_OUTPUT_FORMAT} \
    -r ${REDUCERS_NUMBER} \
    $INPUT_SORT $OUTPUT_SORT"

if [ $(cat $TMPLOGFILE | grep -i -E "job failed|FinalApplicationStatus=FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
