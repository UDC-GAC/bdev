#!/bin/sh

${HDFS_CMD} ${RMR} $OUTPUT_CC

run_benchmark "$FLAMEMR_HOME/bin/flame-mr ${FLAMEMR_WORKLOADS_JAR} es.udc.gac.flamemr.workloads.ConnectedComponents \
		${INPUT_CC}/edges ${OUTPUT_CC} \
		${CC_PAGES} ${REDUCERS_NUMBER} ${CC_MAX_ITERATIONS} nosym new"

if [ $(cat $TMPLOGFILE | grep -i -E 'job failed|FinalApplicationStatus=FAILED|Exception in thread "main"' | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
