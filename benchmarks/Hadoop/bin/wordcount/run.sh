#!/bin/bash

storage_rm -R ${OUTPUT_WORDCOUNT}

run_benchmark "$HADOOP_EXECUTABLE jar $HADOOP_EXAMPLES_JAR wordcount \
    -D $CONFIG_REDUCER_NUMBER=${REDUCERS_NUMBER} \
    -D mapreduce.job.inputformat.class=${EXAMPLES_INPUT_FORMAT} \
    -D mapreduce.job.outputformat.class=${EXAMPLES_OUTPUT_FORMAT} \
    $INPUT_WORDCOUNT $OUTPUT_WORDCOUNT"

