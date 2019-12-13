#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_GREP

run_benchmark "$FLAMEMR_HOME/bin/flame-mr $HADOOP_EXAMPLES_JAR grep \
	-D $CONFIG_REDUCER_NUMBER=${REDUCERS_NUMBER} \
	-D mapreduce.job.inputformat.class=${EXAMPLES_INPUT_FORMAT} \
	-D mapreduce.job.outputformat.class=${EXAMPLES_OUTPUT_FORMAT} \
	$INPUT_GREP $OUTPUT_GREP $GREP_REGEX"

if [ $(cat $TMPLOGFILE | grep -i -E "job failed|FinalApplicationStatus=FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
