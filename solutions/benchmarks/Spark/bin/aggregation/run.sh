#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_AGGREGATION

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/uservisits_aggregation.hive
prepare_sql_aggregation ${HIVE_SQL_FILE}

run_benchmark "$SPARK_HOME/bin/spark-submit \
        --class es.udc.gac.sparkbench.rdd.ScalaHiveSQL ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	ScalaHiveSQLAggregation ${HIVE_SQL_FILE}"

if [ $(cat $TMPLOGFILE | grep -i -E "job failed|FinalApplicationStatus=FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
