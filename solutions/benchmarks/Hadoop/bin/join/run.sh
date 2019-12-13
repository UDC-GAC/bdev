#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_JOIN

if [[ "x$HADOOP_MR_VERSION" != "xYARN" ]]
then
        # These lines are needed for Hadoop version 1
        $HADOOP_EXECUTABLE fs ${MKDIR} ${HIVE_TMP_DIR}
	# The root scratch dir: hdfs://XXXX on HDFS should be writable
        $HADOOP_EXECUTABLE fs ${CHMOD} 733 ${HIVE_TMP_DIR}
fi

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/rankings_uservisits_join.hive
prepare_sql_join ${HIVE_SQL_FILE}

run_benchmark "${HIVE_HOME}/bin/hive -f ${HIVE_SQL_FILE}"

if [ $(cat $TMPLOGFILE | grep -i -E "job failed|FinalApplicationStatus=FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
