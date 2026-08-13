#!/bin/sh

storage_rm -R ${OUTPUT_SCAN}

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/uservisits_scan.hive
prepare_sql_scan ${HIVE_SQL_FILE}
init_hive_metastore

run_benchmark "${HIVE_HOME}/bin/hive -f ${HIVE_SQL_FILE}"
