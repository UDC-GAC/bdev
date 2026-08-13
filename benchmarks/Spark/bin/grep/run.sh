#!/bin/sh

storage_rm -R ${OUTPUT_GREP}

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.gac.sparkbench.${SPARK_API}.ScalaGrep ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	$INPUT_GREP $OUTPUT_GREP $GREP_REGEX $EXAMPLES_DATA_FORMAT"
