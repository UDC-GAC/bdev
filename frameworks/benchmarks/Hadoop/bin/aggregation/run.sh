#!/bin/sh

${HDFS_CMD} ${RMR} $OUTPUT_AGGREGATION

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/uservisits_aggregation.hive
prepare_sql_aggregation ${HIVE_SQL_FILE}

run_benchmark "${HIVE_HOME}/bin/hive -f ${HIVE_SQL_FILE}"

if [ $(cat $TMPLOGFILE | grep -i -E "job failed|FinalApplicationStatus=FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
