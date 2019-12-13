#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_PAGERANK

run_benchmark "$HADOOP_EXECUTABLE jar ${PEGASUS_JAR} pegasus.PagerankNaive \
		${INPUT_PAGERANK}/edges ${OUTPUT_PAGERANK} \
		${PAGERANK_PAGES} ${REDUCERS_NUMBER} ${PAGERANK_MAX_ITERATIONS} nosym new"

if [ $(cat $TMPLOGFILE | grep -i -E 'job failed|FinalApplicationStatus=FAILED|Exception in thread "main"' | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
