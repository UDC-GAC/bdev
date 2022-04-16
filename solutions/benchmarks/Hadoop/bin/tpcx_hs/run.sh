#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_TPCX_HS

run_benchmark "$HADOOP_EXECUTABLE jar $TPCX_HS_JAR HSSort \
    -D $CONFIG_MAP_NUMBER=${MAPPERS_NUMBER} \
    -D $CONFIG_REDUCER_NUMBER=${REDUCERS_NUMBER} \
    $INPUT_TPCX_HS $OUTPUT_TPCX_HS"

if [ $(cat $TMPLOGFILE | grep -i -E "job failed|FinalApplicationStatus=FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi