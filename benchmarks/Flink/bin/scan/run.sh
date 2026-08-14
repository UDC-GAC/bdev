#!/bin/sh

storage_rm -R ${OUTPUT_SCAN}

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/uservisits_scan.hive
prepare_sql_scan ${HIVE_SQL_FILE}

run_benchmark "$FLINK_HOME/bin/flink \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.sql.ScalaHiveSQL $FLINK_BENCH_JAR \
	ScalaHiveSQLScan ${HIVE_SQL_FILE}"
