#!/bin/bash

storage_rm -R ${OUTPUT_GREP}

run_benchmark "$HADOOP_EXECUTABLE jar $HADOOP_EXAMPLES_JAR grep \
	-D $CONFIG_REDUCER_NUMBER=${REDUCERS_NUMBER} \
	-D mapreduce.job.inputformat.class=${EXAMPLES_INPUT_FORMAT} \
	-D mapreduce.job.outputformat.class=${EXAMPLES_OUTPUT_FORMAT} \
	$INPUT_GREP $OUTPUT_GREP $GREP_REGEX"
