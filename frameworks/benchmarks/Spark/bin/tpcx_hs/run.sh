#!/bin/sh

${HDFS_CMD} ${RMR} $OUTPUT_TPCX_HS

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.tpcx_hs.spark.${SPARK_HSSORT_IMPL} ${DEPLOY_ARGS} $TPCX_HS_JAR \
	$INPUT_TPCX_HS $OUTPUT_TPCX_HS"

if [ $(cat $TMPLOGFILE | grep -i -E "final status: FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
