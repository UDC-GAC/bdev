#!/bin/sh

storage_rm -R ${OUTPUT_AGGREGATION}

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/uservisits_aggregation.hive
prepare_sql_aggregation ${HIVE_SQL_FILE}

run_benchmark "$SPARK_HOME/bin/spark-submit \
        --class es.udc.gac.sparkbench.rdd.ScalaHiveSQL ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	ScalaHiveSQLAggregation ${HIVE_SQL_FILE}"
