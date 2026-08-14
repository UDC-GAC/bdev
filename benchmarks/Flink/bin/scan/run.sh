#!/bin/sh

storage_rm -R ${OUTPUT_JOIN}

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/rankings_uservisits_join.hive
prepare_sql_join ${HIVE_SQL_FILE}

run_benchmark "$FLINK_HOME/bin/flink \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.sql.ScalaHiveSQL $FLINK_BENCH_JAR \
	ScalaHiveSQLJoin ${HIVE_SQL_FILE}"
