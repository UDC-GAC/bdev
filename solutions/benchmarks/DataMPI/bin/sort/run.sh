#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_SORT


run_benchmark "${DATAMPI_HOME}/bin/mpidrun \
        -f ${HOSTFILE} -mode COM \
        -O ${MAPPERS_NUMBER} -A ${REDUCERS_NUMBER}  \
        -jar ${DATAMPI_BENCH_JAR} dmb.Sort \
        ${HADOOP_CONF_DIR}/core-site.xml ${INPUT_SORT} ${OUTPUT_SORT} text \
        0.7 1024 4 0.7"

if [ $(cat $TMPLOGFILE | grep -i -E "job failed|FinalApplicationStatus=FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
