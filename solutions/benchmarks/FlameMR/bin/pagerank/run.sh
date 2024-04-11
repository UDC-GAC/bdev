#!/bin/sh

${HDFS_CMD} ${RMR} $OUTPUT_PAGERANK

run_benchmark "$FLAMEMR_HOME/bin/flame-mr ${FLAMEMR_WORKLOADS_JAR} es.udc.gac.flamemr.workloads.PageRank \
		${INPUT_PAGERANK}/edges ${OUTPUT_PAGERANK} \
		${PAGERANK_PAGES} ${REDUCERS_NUMBER} ${PAGERANK_MAX_ITERATIONS} nosym new"

if [ $(cat $TMPLOGFILE | grep -i -E 'job failed|FinalApplicationStatus=FAILED|Exception in thread "main"' | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
