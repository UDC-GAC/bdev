#!/bin/sh

storage_rm -R ${OUTPUT_BAYES}

run_benchmark "$SPARK_HOME/bin/spark-submit \
	--class es.udc.gac.sparkbench.${SPARK_API}.ScalaMLlibSparseNaiveBayes ${DEPLOY_ARGS} $SPARK_BENCH_JAR \
	${INPUT_BAYES} ${OUTPUT_BAYES}/model"
