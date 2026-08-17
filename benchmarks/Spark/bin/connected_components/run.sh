#!/bin/sh

storage_rm -R ${OUTPUT_CC}

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.gac.sparkbench.${SPARK_API}.ScalaConnectedComponents ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	${INPUT_CC}/edges ${OUTPUT_CC} ${CC_PAGES} ${CC_MAX_ITERATIONS}"
