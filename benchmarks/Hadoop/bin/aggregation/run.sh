#!/bin/sh

storage_rm -R ${OUTPUT_AGGREGATION}

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/uservisits_aggregation.hive
prepare_sql_aggregation ${HIVE_SQL_FILE}
init_hive_metastore

run_benchmark "${HIVE_HOME}/bin/hive -f ${HIVE_SQL_FILE}"
