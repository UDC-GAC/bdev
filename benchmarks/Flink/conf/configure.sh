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
	
if [ "$GEN_TPCX_HS" == "true" ]; then
	if [ $FLINK_SERIES == "1" ]; then
		export FLINK_TPCX_HS_JAR_NAME=tpcx-hs-flink-1.14.0_${FLINK_SCALA_VERSION}.jar
		export TPCX_HS_JAR=$FLINK_BENCH_DIR/$FLINK_TPCX_HS_JAR_NAME
	else
        m_exit "Flink version is not supported: $FLINK_VERSION"
	fi

	if [ ! -f $TPCX_HS_JAR ]; then
		# Download TPCx-HS jar file
		URL=https://bdev.des.udc.es/dist/tpcx-hs
		m_echo "Downloading $FLINK_TPCX_HS_JAR_NAME from $URL"

    	wget -q -O $TPCX_HS_JAR $URL/$FLINK_TPCX_HS_JAR_NAME

    	if [ $? != 0 ]; then
			rm $TPCX_HS_JAR >& /dev/null
			m_exit "Error when downloading $FLINK_TPCX_HS_JAR_NAME"
    	fi
	else
		m_echo "Using $TPCX_HS_JAR"
	fi
fi
