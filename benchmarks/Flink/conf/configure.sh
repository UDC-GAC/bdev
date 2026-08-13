#!/bin/sh

export SORT_PARTITIONS=$FLINK_PARALLELISM
export FLINK_BENCH_JAR_NAME=flinkbench-1.0_${FLINK_SCALA_VERSION}.jar
export FLINK_BENCH_DIR=$SOL_BENCH_DIR/bin
export FLINK_BENCH_JAR=$FLINK_BENCH_DIR/$FLINK_BENCH_JAR_NAME

if [ ! -f $FLINK_BENCH_JAR ]; then
    # Download flinkbench jar file
    URL=https://bdev.des.udc.es/dist/flinkbench
    m_echo "Downloading $FLINK_BENCH_JAR_NAME"

    wget -q -O $FLINK_BENCH_JAR $URL/$FLINK_BENCH_JAR_NAME

    if [[ $? != 0 ]]; then
		rm $FLINK_BENCH_JAR >& /dev/null
        m_exit "Error when downloading $FLINK_BENCH_JAR_NAME"
    fi
else
	m_echo "Using $FLINK_BENCH_JAR"
fi
	

if [ "$BENCHMARK" == "tpcx_hs" ]; then
	if [ $FLINK_SERIES == "1" ]; then
		export FINK_TCPX_HS_JAR=$SPARK_BENCH_DIR/$FLINK_TCPX_HS_JAR_NAME
		export FLINK_TCPX_HS_JAR_NAME=tpcx-hs-flink-1.14.0_${FLINK_SCALA_VERSION}.jar
	else
        m_exit "Flink version is not supported: $FLINK_VERSION"
	fi
	
	# Download TPCx-HS jar file
	URL=https://bdev.des.udc.es/dist/tpcx-hs
	m_echo "Downloading $FLINK_TCPX_HS_JAR_NAME from $URL"

    wget -q -O $FINK_TCPX_HS_JAR $URL/$FLINK_TCPX_HS_JAR_NAME

    if [ $? != 0 ]; then
		rm $FINK_TCPX_HS_JAR >& /dev/null
		m_exit "Error when downloading $FLINK_TCPX_HS_JAR_NAME"
    fi
else
	m_echo "Using $FINK_TCPX_HS_JAR"
fi
