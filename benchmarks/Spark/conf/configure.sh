#!/bin/bash

if [[ "$SPARK_SERIES" == "2" ]]; then
	SPARK_BENCH_JAR_NAME="sparkbench-2.4.0_${SPARK_SCALA_VERSION}.jar"
	SPARK_TPCX_HS_JAR_NAME="tpcx-hs-spark-2.4.0_${SPARK_SCALA_VERSION}.jar"
else
	case "$SPARK_MAJOR_VERSION" in
   		3.0|3.1)
        		SPARK_BENCH_JAR_NAME="sparkbench-3.0.0_${SPARK_SCALA_VERSION}.jar"
			SPARK_TPCX_HS_JAR_NAME="tpcx-hs-spark-3.0.0_${SPARK_SCALA_VERSION}.jar"
        	;;
    		3.2|3.3|3.4|3.5)
        		SPARK_BENCH_JAR_NAME="sparkbench-3.2.0_${SPARK_SCALA_VERSION}.jar"
			SPARK_TPCX_HS_JAR_NAME="tpcx-hs-spark-3.2.0_${SPARK_SCALA_VERSION}.jar"
        	;;
    		4.0|4.1|4.2)
		    	SPARK_BENCH_JAR_NAME="sparkbench-4.0.0_${SPARK_SCALA_VERSION}.jar"
			SPARK_TPCX_HS_JAR_NAME="tpcx-hs-spark-4.0.0_${SPARK_SCALA_VERSION}.jar"
        	;;
		*)
			m_exit "Spark version is not supported: $SPARK_VERSION"
        	;;
	esac
fi

export SORT_PARTITIONS=$(($SPARK_EXECUTORS * $SPARK_CORES_PER_EXECUTOR))

# SparkBench JAR
export SPARK_BENCH_JAR="$BDEV_LIB_DIR/$SPARK_BENCH_JAR_NAME"
download_jar_if_missing "$SPARK_BENCH_JAR" "$BDEV_WEBPAGE/dist/sparkbench/$SPARK_BENCH_JAR_NAME" "$SPARK_BENCH_JAR_NAME"
m_echo "Using $SPARK_BENCH_JAR"

# TPCx-HS Benchmark JAR
if [[ "$GEN_TPCX_HS" == "true" ]]; then
	export TPCX_HS_JAR="$BDEV_LIB_DIR/$SPARK_TPCX_HS_JAR_NAME"
	download_jar_if_missing "$TPCX_HS_JAR" \
		"$BDEV_WEBPAGE/dist/tpcx-hs/$SPARK_TPCX_HS_JAR_NAME" \
		"$SPARK_TPCX_HS_JAR_NAME"
    m_echo "Using $TPCX_HS_JAR"
fi
