#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_JOIN

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/rankings_uservisits_join.hive
prepare_sql_join ${HIVE_SQL_FILE}

run_benchmark "$SPARK_HOME/bin/spark-submit \
        --class es.udc.gac.sparkbench.rdd.ScalaHiveSQL ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	ScalaHiveSQLJoin ${HIVE_SQL_FILE}"

if [ $(cat $TMPLOGFILE | grep -i -E "job failed|FinalApplicationStatus=FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
