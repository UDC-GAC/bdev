#!/bin/sh

export SORT_PARTITIONS=$FLINK_PARALLELISM
# Hardcode last scala version supported by Flink 1.x
# From Flink 2.x onwards, Flink is scala-free
export FLINK_SCALA_VERSION=2.12
export FLINK_LIB="$FLINK_HOME/lib"
export FLINK_OPT="$FLINK_HOME/opt"
export FLINK_BENCH_JAR_NAME=flinkbench-1.0_${FLINK_SCALA_VERSION}.jar
export FLINK_BENCH_DIR=$SOL_BENCH_DIR/bin
export FLINK_BENCH_JAR=$FLINK_BENCH_DIR/$FLINK_BENCH_JAR_NAME
export FLINK_HADOOP_COMPATIBILITY_JAR="flink-hadoop-compatibility_${FLINK_SCALA_VERSION}-${FLINK_VERSION}.jar"
export FLINK_HADOOP_COMPATIBILITY_PATH="${FLINK_LIB}/${FLINK_HADOOP_COMPATIBILITY_JAR}"
export FLINK_HADOOP_COMPATIBILITY_URL="https://repo1.maven.org/maven2/org/apache/flink/flink-hadoop-compatibility_${FLINK_SCALA_VERSION}/${FLINK_VERSION}/${FLINK_HADOOP_COMPATIBILITY_JAR}"
export FLINK_SQL_CONNECTOR_HIVE_JAR="flink-connector-hive-${FLINK_HIVE_VERSION}_${FLINK_SCALA_VERSION}-${FLINK_VERSION}.jar"
export FLINK_SQL_CONNECTOR_HIVE_PATH="${FLINK_LIB}/${FLINK_SQL_CONNECTOR_HIVE_JAR}"
export FLINK_SQL_CONNECTOR_HIVE_URL="https://repo1.maven.org/maven2/org/apache/flink/flink-connector-hive-${FLINK_HIVE_VERSION}_${FLINK_SCALA_VERSION}/${FLINK_VERSION}/${FLINK_SQL_CONNECTOR_HIVE_JAR}"


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

if [ ! -f "$FLINK_HADOOP_COMPATIBILITY_PATH" ]; then
    m_echo "Flink Hadoop compatibility JAR not found: $FLINK_HADOOP_COMPATIBILITY_PATH"
    m_echo "Downloading $FLINK_HADOOP_COMPATIBILITY_URL..."

    TMP_JAR="${FLINK_HADOOP_COMPATIBILITY_PATH}.tmp"

    if ! wget -q -O "$TMP_JAR" "$FLINK_HADOOP_COMPATIBILITY_URL" || [ ! -s "$TMP_JAR" ]; then
        rm -f "$TMP_JAR"
        m_exit "Could not download $FLINK_HADOOP_COMPATIBILITY_JAR. Please download it manually and copy it to ${FLINK_LIB}"
    fi

    if ! mv "$TMP_JAR" "$FLINK_HADOOP_COMPATIBILITY_PATH"; then
    	rm -f "$TMP_JAR"
        m_exit "Could not install $FLINK_HADOOP_COMPATIBILITY_JAR into $FLINK_LIB"
    fi
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
	# Remove the isolated loader from lib/ so it stops interfering
	mv "$FLINK_LIB"/flink-table-planner-loader-*.jar "$FLINK_OPT"/ 2>/dev/null || true
	# Copy the real planner
	find "$FLINK_OPT" -maxdepth 1 -name "flink-table-planner*.jar" ! -name "*loader*" -exec cp {} "$FLINK_LIB/" \;

	if [ ! -f "$FLINK_SQL_CONNECTOR_HIVE_PATH" ]; then
    	m_echo "Flink SQL connector for Hive $FLINK_HIVE_VERSION not found: $FLINK_SQL_CONNECTOR_HIVE_PATH"
    	m_echo "Downloading $FLINK_SQL_CONNECTOR_HIVE_URL..."

    	TMP_JAR="${FLINK_SQL_CONNECTOR_HIVE_PATH}.tmp"

   		if ! wget -q -O "$TMP_JAR" "$FLINK_SQL_CONNECTOR_HIVE_URL" || [ ! -s "$TMP_JAR" ]; then
        	rm -f "$TMP_JAR"
        	m_exit "Could not download $FLINK_SQL_CONNECTOR_HIVE_JAR. Please download it manually and copy it to ${FLINK_LIB}"
    	fi

    	if ! mv "$TMP_JAR" "$FLINK_SQL_CONNECTOR_HIVE_PATH"; then
        	rm -f "$TMP_JAR"
        	m_exit "Could not install $FLINK_SQL_CONNECTOR_HIVE_JAR into $FLINK_LIB"
    	fi
	fi
fi
