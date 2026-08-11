#!/bin/sh

storage_rm -R ${OUTPUT_TPCX_HS}

run_benchmark "$FLINK_HOME/bin/flink \
	${DEPLOY_ARGS} \
	--class es.udc.tpcx_hs.flink.HSSort $TPCX_HS_JAR \
	$INPUT_TPCX_HS $OUTPUT_TPCX_HS"

if [ $(cat $TMPLOGFILE | grep -i -E "Job execution switched to status FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
