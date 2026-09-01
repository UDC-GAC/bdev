#!/bin/bash

storage_rm -R ${OUTPUT_PAGERANK}

run_benchmark "$HADOOP_EXECUTABLE jar ${PEGASUS_JAR} pegasus.PagerankNaive \
		${INPUT_PAGERANK}/edges ${OUTPUT_PAGERANK} \
		${PAGERANK_PAGES} ${REDUCERS_NUMBER} ${PAGERANK_MAX_ITERATIONS} nosym new"
