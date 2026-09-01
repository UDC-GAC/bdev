#!/bin/bash

storage_rm -R ${OUTPUT_JOIN}

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/rankings_uservisits_join.hive
prepare_sql_join ${HIVE_SQL_FILE}

run_benchmark "$SPARK_HOME/bin/spark-submit \
        --class es.udc.gac.sparkbench.sql.ScalaHiveSQL ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	ScalaHiveSQLJoin ${HIVE_SQL_FILE}"
