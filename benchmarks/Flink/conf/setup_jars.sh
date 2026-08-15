#!/bin/sh

# Hardcode last scala version supported by Flink 1.x
# From Flink 2.x onwards, Flink is scala-free
export FLINK_SCALA_VERSION=2.12
export FLINK_LIB="$FLINK_HOME/lib"
export FLINK_OPT="$FLINK_HOME/opt"
export FLINK_HADOOP_COMPATIBILITY_JAR="flink-hadoop-compatibility_${FLINK_SCALA_VERSION}-${FLINK_VERSION}.jar"
export FLINK_HADOOP_COMPATIBILITY_PATH="${FLINK_LIB}/${FLINK_HADOOP_COMPATIBILITY_JAR}"
export FLINK_HADOOP_COMPATIBILITY_URL="https://repo1.maven.org/maven2/org/apache/flink/flink-hadoop-compatibility_${FLINK_SCALA_VERSION}/${FLINK_VERSION}/${FLINK_HADOOP_COMPATIBILITY_JAR}"
export FLINK_SQL_CONNECTOR_HIVE_JAR="flink-sql-connector-hive-${FLINK_HIVE_VERSION}_${FLINK_SCALA_VERSION}-${FLINK_VERSION}.jar"
export FLINK_SQL_CONNECTOR_HIVE_PATH="${FLINK_LIB}/${FLINK_SQL_CONNECTOR_HIVE_JAR}"
export FLINK_SQL_CONNECTOR_HIVE_URL="https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-hive-${FLINK_HIVE_VERSION}_${FLINK_SCALA_VERSION}/${FLINK_VERSION}/${FLINK_SQL_CONNECTOR_HIVE_JAR}"
export MAPREDUCE_JAR_FILE=$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-core-*.jar

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

if [ ! -f $MAPREDUCE_JAR_FILE ]; then
	m_exit "MapReduce jar not found: $MAPREDUCE_JAR_FILE"
else
	cp -f $MAPREDUCE_JAR_FILE $FLINK_LIB
fi

if [ $GEN_AGGREGATION == "true" ] || [ $GEN_JOIN == "true" ] || [ $GEN_SCAN == "true" ]; then
	# Remove the isolated loader from lib/ so it stops interfering
	mv "$FLINK_LIB"/flink-table-planner-loader-*.jar "$FLINK_OPT"/ 2>/dev/null || true
	# Copy the real planner
	find "$FLINK_OPT" -maxdepth 1 -name "flink-table-planner*.jar" ! -name "*loader*" -exec cp {} "$FLINK_LIB/" \;

	if [ ! -f "$FLINK_SQL_CONNECTOR_HIVE_PATH" ]; then
    	m_echo "Flink SQL connector for Hive not found: $FLINK_SQL_CONNECTOR_HIVE_PATH"
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

	if [ -z $HIVE_HOME ]; then
		m_exit "HIVE_HOME is not defined or is empty"
	fi
	
	if [ -d $HIVE_HOME ]; then
		HIVE_LIB="${HIVE_HOME}/lib"	
		# We built a string with all the JARs separated by ':', EXCLUDING calcite
		HIVE_FILTERED_CLASSPATH=$(find "$HIVE_LIB" -maxdepth 1 -name "*.jar" ! -name "calcite-*.jar" | tr '\n' ':' | sed 's/:$//')
		#export HADOOP_CLASSPATH="$HADOOP_CLASSPATH:$HIVE_FILTERED_CLASSPATH"
	else
		m_exit "HIVE_HOME does not exist or is not a directory: $HIVE_HOME"
	fi
fi
