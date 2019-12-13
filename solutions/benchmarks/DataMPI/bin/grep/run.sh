#!/bin/sh

GREP_TMP_PATH=${OUTPUT_GREP}_tmp

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_GREP


run_benchmark "${DATAMPI_HOME}/bin/mpidrun \
        -f ${HOSTFILE} -mode COM \
        -O ${MAPPERS_NUMBER} -A ${REDUCERS_NUMBER} \
        -jar ${DATAMPI_BENCH_JAR} dmb.Grep \
        ${HADOOP_CONF_DIR}/core-site.xml ${INPUT_GREP} ${GREP_TMP_PATH} grep ${GREP_REGEX} \
        0.7 1024 4 0.7 ; \
	$HADOOP_EXECUTABLE fs ${RMR} ${GREP_TMP_PATH}/_* ; \
	${DATAMPI_HOME}/bin/mpidrun \
	-f ${HOSTFILE} -mode COM \
	-O ${MAPPERS_NUMBER} -A 1 \
	-jar ${DATAMPI_BENCH_JAR} dmb.Grep \
	${HADOOP_CONF_DIR}/core-site.xml ${GREP_TMP_PATH} ${OUTPUT_GREP} sortgrep ; \
	$HADOOP_EXECUTABLE fs ${RMR} ${GREP_TMP_PATH}"

if [ $(cat $TMPLOGFILE | grep -i -E "job failed|FinalApplicationStatus=FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
