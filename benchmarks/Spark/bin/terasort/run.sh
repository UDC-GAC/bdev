#!/bin/sh

storage_rm -R ${OUTPUT_TERASORT}

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.gac.sparkbench.${SPARK_API}.ScalaTeraSort ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	$INPUT_TERASORT $OUTPUT_TERASORT"
