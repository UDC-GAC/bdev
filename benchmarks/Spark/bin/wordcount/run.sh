#!/bin/sh

storage_rm -R ${OUTPUT_WORDCOUNT}

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.gac.sparkbench.${SPARK_API}.ScalaWordCount ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	$INPUT_WORDCOUNT $OUTPUT_WORDCOUNT $EXAMPLES_DATA_FORMAT"
