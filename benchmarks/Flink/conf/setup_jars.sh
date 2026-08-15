#!/bin/sh

# Hardcode last scala version supported by Flink 1.x
# From Flink 2.x onwards, Flink is scala-free
export FLINK_SCALA_VERSION=2.12
export FLINK_LIB="$FLINK_HOME/lib"
export FLINK_OPT="$FLINK_HOME/opt"
export FLINK_HADOOP_COMPATIBILITY_JAR="flink-hadoop-compatibility_${FLINK_SCALA_VERSION}-${FLINK_VERSION}.jar"
export FLINK_HADOOP_COMPATIBILITY_PATH="${FLINK_LIB}/${FLINK_HADOOP_COMPATIBILITY_JAR}"
export FLINK_HADOOP_COMPATIBILITY_URL="https://repo1.maven.org/maven2/org/apache/flink/flink-hadoop-compatibility_${FLINK_SCALA_VERSION}/${FLINK_VERSION}/${FLINK_HADOOP_COMPATIBILITY_JAR}"
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
	if [ $FLINK_SERIES == "1" ]; then
		if [ $FLINK_MAJOR_VERSION != "1.20" ] &&
			[ $FLINK_MAJOR_VERSION != "1.19" ] &&
			[ $FLINK_MAJOR_VERSION != "1.18" ] &&
			[ $FLINK_MAJOR_VERSION != "1.17" ] &&
			[ $FLINK_MAJOR_VERSION != "1.16" ] &&
			[ $FLINK_MAJOR_VERSION != "1.15" ]; then
			m_exit "Flink version is not supported: $FLINK_VERSION"
		fi
	else
        m_exit "Flink version is not supported: $FLINK_VERSION"
	fi
	
	if [ $FLINK_MAJOR_VERSION == "1.15" ] || [ $FLINK_MAJOR_VERSION == "1.16" ] || [ $FLINK_MAJOR_VERSION == "1.17" ]; then
		FLINK_HIVE_VERSION=3.1.2
		# Remove the isolated loader from lib/ so it stops interfering
		mv "$FLINK_LIB"/flink-table-planner-loader-*.jar "$FLINK_OPT"/ 2>/dev/null || true
		# Copy the real planner
		find "$FLINK_OPT" -maxdepth 1 -name "flink-table-planner*.jar" ! -name "*loader*" -exec cp {} "$FLINK_LIB/" \;
	else
		FLINK_HIVE_VERSION=3.1.3
		# In 1.18+: The loader must be in lib/
		if ls "$FLINK_OPT"/flink-table-planner-loader-*.jar 1>/dev/null 2>&1; then
			mv "$FLINK_OPT"/flink-table-planner-loader-*.jar "$FLINK_LIB/"
		fi
		
		find "$FLINK_LIB" -maxdepth 1 -name "flink-table-planner*.jar" ! -name "*loader*" -delete 2>/dev/null || true
	fi
	
	FLINK_SQL_CONNECTOR_HIVE_JAR="flink-sql-connector-hive-${FLINK_HIVE_VERSION}_${FLINK_SCALA_VERSION}-${FLINK_VERSION}.jar"
	FLINK_SQL_CONNECTOR_HIVE_PATH="${FLINK_LIB}/${FLINK_SQL_CONNECTOR_HIVE_JAR}"
	FLINK_SQL_CONNECTOR_HIVE_URL="https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-hive-${FLINK_HIVE_VERSION}_${FLINK_SCALA_VERSION}/${FLINK_VERSION}/${FLINK_SQL_CONNECTOR_HIVE_JAR}"
	
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

	if [ -z $HIVE_HOME ]; then
		m_exit "HIVE_HOME is not defined or is empty"
	fi
	
	if [ -d $HIVE_HOME ]; then
		HIVE_LIB="${HIVE_HOME}/lib"
		HIVE_FILTERED_CLASSPATH=$HADOOP_CLASSPATH
		
		for f in "$HIVE_LIB"/datanucleus-*.jar "$HIVE_LIB"/javax.jdo-*.jar "$HIVE_LIB"/derby-*.jar "$HIVE_LIB"/transaction-api-*.jar; do
    		if [ -f "$f" ]; then
        		HIVE_FILTERED_CLASSPATH="$HIVE_FILTERED_CLASSPATH:$f"
    		fi
		done
	
		export HADOOP_CLASSPATH=$HIVE_FILTERED_CLASSPATH
	else
		m_exit "HIVE_HOME does not exist or is not a directory: $HIVE_HOME"
	fi
fi
