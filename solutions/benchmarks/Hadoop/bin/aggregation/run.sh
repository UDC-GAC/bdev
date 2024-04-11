#!/bin/sh

${HDFS_CMD} ${RMR} $OUTPUT_AGGREGATION

if [[ "x$HADOOP_MR_VERSION" != "xYARN" ]]
then
	# These lines are needed for Hadoop version 1
        ${HDFS_CMD} ${MKDIR} ${HIVE_TMP_DIR}
        # The root scratch dir: hdfs://XXXX on HDFS should be writable
        ${HDFS_CMD} ${CHMOD} 733 ${HIVE_TMP_DIR}
fi

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/uservisits_aggregation.hive
prepare_sql_aggregation ${HIVE_SQL_FILE}

run_benchmark "${HIVE_HOME}/bin/hive -f ${HIVE_SQL_FILE}"

if [ $(cat $TMPLOGFILE | grep -i -E "job failed|FinalApplicationStatus=FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
