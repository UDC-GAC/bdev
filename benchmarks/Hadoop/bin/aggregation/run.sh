#!/bin/bash

storage_rm -R ${OUTPUT_AGGREGATION}

HIVE_SQL_FILE=${BENCHMARK_OUTPUT_DIR}/uservisits_aggregation.hive
prepare_sql_aggregation ${HIVE_SQL_FILE}
init_hive_metastore

run_benchmark "${HIVE_HOME}/bin/beeline -u jdbc:hive2:// ${HIVE_OPTS} -f ${HIVE_SQL_FILE}"
