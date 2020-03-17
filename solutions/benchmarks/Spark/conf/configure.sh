#!/bin/sh

export SORT_PARTITIONS=$(($SPARK_EXECUTORS * $SPARK_CORES_PER_EXECUTOR))
export SPARK_BENCH_JAR_NAME=sparkbench-assembly-2.0.jar

if [[ $SPARK_SERIES == "3" ]]
then
	export SPARK_BENCH_JAR_NAME=sparkbench-assembly-3.0.jar
fi

export SPARK_BENCH_JAR=$SOL_BENCH_DIR/bin/$SPARK_BENCH_JAR_NAME
export SPARK_BENCH_JAR_DELETE="find $SOLUTION_REPORT_DIR -name "$SPARK_BENCH_JAR_NAME" -type f -delete"

if [[ ! -f $SPARK_BENCH_JAR ]]
then
	# Download sparkbench jar file
	URL="http://bdev.des.udc.es/dist/sparkbench"
	m_echo "Downloading $SPARK_BENCH_JAR_NAME"

        wget -q -O $SPARK_BENCH_JAR $URL/$SPARK_BENCH_JAR_NAME

        if [[ $? != 0 ]]
        then
		m_exit "Error when downloading $SPARK_BENCH_JAR_NAME"
        fi
fi
