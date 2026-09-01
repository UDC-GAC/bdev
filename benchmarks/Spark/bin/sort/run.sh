#!/bin/bash

storage_rm -R ${OUTPUT_SORT}

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.gac.sparkbench.${SPARK_API}.ScalaSort ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	$INPUT_SORT $OUTPUT_SORT $EXAMPLES_DATA_FORMAT"
