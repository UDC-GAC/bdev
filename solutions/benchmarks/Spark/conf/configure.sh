#!/bin/sh

export SORT_PARTITIONS=$(($SPARK_EXECUTORS * $SPARK_CORES_PER_EXECUTOR))
export SPARK_BENCH_JAR_NAME=sparkbench-2.4_${SPARK_SCALA_VERSION}.jar

if [[ $SPARK_SERIES == "1" ]]
then
	export SPARK_BENCH_JAR_NAME=sparkbench-1.6_${SPARK_SCALA_VERSION}.jar
	# Spark GraphX 1.x does not support iterative ConnCompt
	export CC_MAX_ITERATIONS=1024
fi

if [[ $SPARK_SERIES == "3" ]]
then
	export SPARK_BENCH_JAR_NAME=sparkbench-3.0_${SPARK_SCALA_VERSION}.jar
fi

export SPARK_BENCH_DIR=$SOL_BENCH_DIR/bin
export SPARK_BENCH_JAR=$SPARK_BENCH_DIR/$SPARK_BENCH_JAR_NAME
export SPARK_BENCH_JAR_DELETE="find $SOLUTION_REPORT_DIR -name "$SPARK_BENCH_JAR_NAME" -type f -delete"

if [[ "$BENCHMARK" == "tpcx_hs" ]]
then
	m_echo "Using $TPCX_HS_JAR"
elif [[ ! -f $SPARK_BENCH_JAR ]]
then
	# Download sparkbench jar file
	URL=https://bdev.des.udc.es/dist/sparkbench
	m_echo "Downloading $SPARK_BENCH_JAR_NAME from $URL"

        wget -q -O $SPARK_BENCH_JAR $URL/$SPARK_BENCH_JAR_NAME

        if [[ $? != 0 ]]
        then
		rm $SPARK_BENCH_JAR >& /dev/null
		m_exit "Error when downloading $SPARK_BENCH_JAR_NAME"
        fi
else
	m_echo "Using $SPARK_BENCH_JAR"
fi
