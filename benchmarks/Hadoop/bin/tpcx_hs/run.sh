#!/bin/bash

storage_rm -R ${OUTPUT_TPCX_HS}

run_benchmark "$HADOOP_EXECUTABLE jar $TPCX_HS_JAR es.udc.tpcx_hs.hadoop.HSSort \
	-D $CONFIG_REDUCER_NUMBER=${REDUCERS_NUMBER} $INPUT_TPCX_HS $OUTPUT_TPCX_HS"
