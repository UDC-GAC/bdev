#!/bin/sh

export SORT_PARTITIONS=$FLINK_PARALLELISM
# Hardcode last scala version supported by Flink 1.x
# From Flink 2.x onwards, Flink is scala-free
export FLINK_SCALA_VERSION=2.12
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
		export FLINK_TPCX_HS_JAR_NAME=tpcx-hs-flink-1.0_${FLINK_SCALA_VERSION}.jar
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

if [ $GEN_AGGREGATION == "true" ] || [ $GEN_JOIN == "true" ] || [ $GEN_SCAN == "true" ]; then
	if [ $FLINK_MAJOR_VERSION == "1.15" ] || [ $FLINK_MAJOR_VERSION == "1.16" ]; then
		export FLINK_HIVE_VERSION=3.1.2
	else
		export FLINK_HIVE_VERSION=3.1.3
	fi

	HIVE_LIB="${HIVE_HOME}/lib"

	for f in "$HIVE_LIB"/datanucleus-*.jar "$HIVE_LIB"/javax.jdo-*.jar "$HIVE_LIB"/derby-*.jar "$HIVE_LIB"//transaction-api-*.jar; do
    	if [ -f "$f" ]; then
        	cp ${f} ${FLINK_HOME}/lib
    	fi
	done
fi
