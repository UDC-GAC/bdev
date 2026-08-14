#!/bin/sh

storage_rm -R ${OUTPUT_AGGREGATION}

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/uservisits_aggregation.hive
prepare_sql_aggregation ${HIVE_SQL_FILE}

run_benchmark "$FLINK_HOME/bin/flink \
	${DEPLOY_ARGS} \
	--class es.udc.gac.flinkbench.sql.ScalaHiveSQL $FLINK_BENCH_JAR \
	ScalaHiveSQLAggregation ${HIVE_SQL_FILE}"
