#!/bin/sh

export SORT_PARTITIONS=$(($SPARK_EXECUTORS * $SPARK_CORES_PER_EXECUTOR))

if [ $SPARK_SERIES == "2" ]; then
	export SPARK_BENCH_JAR_NAME=sparkbench-2.4_${SPARK_SCALA_VERSION}.jar
	export SPARK_TCPX_HS_JAR_NAME=tpcx-hs-spark-2.4.0_${SPARK_SCALA_VERSION}.jar
else
	case "$SPARK_MAJOR_VERSION" in
   		3.0|3.1)
        	export SPARK_BENCH_JAR_NAME=sparkbench-3.0_${SPARK_SCALA_VERSION}.jar
			export SPARK_TCPX_HS_JAR_NAME=tpcx-hs-spark-3.0.0_${SPARK_SCALA_VERSION}.jar
        	;;
    	3.2|3.3|3.4|3.5)
        	export SPARK_BENCH_JAR_NAME=sparkbench-3.2_${SPARK_SCALA_VERSION}.jar
			export SPARK_TCPX_HS_JAR_NAME=tpcx-hs-spark-3.2.0_${SPARK_SCALA_VERSION}.jar
        	;;
    	4.0|4.1|4.2)
		    export SPARK_BENCH_JAR_NAME=sparkbench-4.0_${SPARK_SCALA_VERSION}.jar
			export SPARK_TCPX_HS_JAR_NAME=tpcx-hs-spark-4.0.0_${SPARK_SCALA_VERSION}.jar
        	;;
		*)
			m_exit "Spark version is not supported: $SPARK_VERSION"
        	;;
	esac
fi

export SPARK_BENCH_DIR=$SOL_BENCH_DIR/bin
export SPARK_BENCH_JAR=$SPARK_BENCH_DIR/$SPARK_BENCH_JAR_NAME
export SPARK_BENCH_JAR_DELETE="find $SOLUTION_REPORT_DIR -name "$SPARK_BENCH_JAR_NAME" -type f -delete"

if [ ! -f $SPARK_BENCH_JAR ]; then
	# Download sparkbench jar file
	URL=https://bdev.des.udc.es/dist/sparkbench
	m_echo "Downloading $SPARK_BENCH_JAR_NAME from $URL"

    wget -q -O $SPARK_BENCH_JAR $URL/$SPARK_BENCH_JAR_NAME

    if [ $? != 0 ]; then
		rm $SPARK_BENCH_JAR >& /dev/null
		m_exit "Error when downloading $SPARK_BENCH_JAR_NAME"
    fi
else
	m_echo "Using $SPARK_BENCH_JAR"
fi

if [ "$BENCHMARK" == "tpcx_hs" ]; then
	export TCPX_HS_JAR=$SPARK_BENCH_DIR/$SPARK_TCPX_HS_JAR_NAME

	# Download TPCx-HS jar file
	URL=https://bdev.des.udc.es/dist/tpcx-hs
	m_echo "Downloading $SPARK_TCPX_HS_JAR_NAME from $URL"

    wget -q -O $TCPX_HS_JAR $URL/$SPARK_TCPX_HS_JAR_NAME

    if [ $? != 0 ]; then
		rm $TCPX_HS_JAR >& /dev/null
		m_exit "Error when downloading $SPARK_TCPX_HS_JAR_NAME"
    fi
else
	m_echo "Using $TCPX_HS_JAR"
fi
