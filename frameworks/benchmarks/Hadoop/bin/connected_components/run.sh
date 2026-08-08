#!/bin/sh

${HDFS_CMD} ${RMR} $OUTPUT_CC

run_benchmark "$HADOOP_EXECUTABLE jar ${PEGASUS_JAR} pegasus.ConCmpt \
		${INPUT_CC}/edges ${OUTPUT_CC} \
		${CC_PAGES} ${REDUCERS_NUMBER} ${CC_MAX_ITERATIONS} nosym new"

if [ $(cat $TMPLOGFILE | grep -i -E 'job failed|FinalApplicationStatus=FAILED|Exception in thread "main"' | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
