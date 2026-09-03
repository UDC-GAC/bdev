#!/bin/bash

storage_rm -R ${OUTPUT_SCAN}

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/uservisits_scan.hive
prepare_sql_scan ${HIVE_SQL_FILE}

run_benchmark "$SPARK_HOME/bin/spark-submit \
        --class es.udc.gac.sparkbench.sql.ScalaHiveSQL ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	ScalaHiveSQLScan ${HIVE_SQL_FILE}"
