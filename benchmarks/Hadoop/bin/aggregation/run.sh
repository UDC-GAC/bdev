#!/bin/sh

storage_rm -R ${OUTPUT_AGGREGATION}

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/uservisits_aggregation.hive
prepare_sql_aggregation ${HIVE_SQL_FILE}
init_hive_metastore
HIVE_COMMAND="${HIVE_HOME}/bin/hive ${HIVE_OPTS} -f ${HIVE_SQL_FILE}"
run_benchmark "${HIVE_COMMAND}"
