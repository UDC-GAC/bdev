#!/bin/bash

# Hardcode last scala version supported by Flink 1.x
# From Flink 2.x onwards, Flink is scala-free
export FLINK_SCALA_VERSION=2.12
export FLINK_LIB="$FLINK_HOME/lib"
export FLINK_OPT="$FLINK_HOME/opt"

if [[ "$FLINK_MAJOR_VERSION" == "1.15" || "$FLINK_MAJOR_VERSION" == "1.16" ]]; then
	export FLINK_HIVE_VERSION=3.1.2
else
	export FLINK_HIVE_VERSION=3.1.3
fi

FLINK_SQL_CONNECTOR_HIVE_JAR="flink-connector-hive_${FLINK_SCALA_VERSION}-${FLINK_VERSION}.jar"
FLINK_SQL_CONNECTOR_HIVE_PATH="${FLINK_LIB}/${FLINK_SQL_CONNECTOR_HIVE_JAR}"
FLINK_SQL_CONNECTOR_HIVE_URL="https://repo1.maven.org/maven2/org/apache/flink/flink-connector-hive_${FLINK_SCALA_VERSION}/${FLINK_VERSION}/${FLINK_SQL_CONNECTOR_HIVE_JAR}"
HIVE_EXEC_CORE_JAR="hive-exec-${FLINK_HIVE_VERSION}-core.jar"
HIVE_EXEC_CORE_PATH="${FLINK_LIB}/${HIVE_EXEC_CORE_JAR}"
HIVE_EXEC_CORE_URL="https://repo1.maven.org/maven2/org/apache/hive/hive-exec/${FLINK_HIVE_VERSION}/${HIVE_EXEC_CORE_JAR}"
HIVE_FILTERED_CLASSPATH="$HADOOP_CLASSPATH"

if [[ "$GEN_AGGREGATION" == "true" || "$GEN_JOIN" == "true" || "$GEN_SCAN" == "true" ]]; then
	if [[ -z "$HIVE_HOME" ]]; then
		m_exit "HIVE_HOME is not defined or is empty"
	fi

	if [[ -d "$HIVE_HOME" ]]; then
		HIVE_LIB="${HIVE_HOME}/lib"
	else
		m_exit "HIVE_HOME does not exist or is not a directory: $HIVE_HOME"
	fi

	if [[ -f "${FLINK_OPT}/${HIVE_EXEC_CORE_JAR}" ]]; then
		if ! mv "${FLINK_OPT}/${HIVE_EXEC_CORE_JAR}" "$FLINK_LIB/"; then
			m_exit "Could not move $HIVE_EXEC_CORE_JAR from $FLINK_OPT to $FLINK_LIB"
    		fi
	elif [[ ! -f "$HIVE_EXEC_CORE_PATH" ]]; then
		m_echo "Hive exec core jar not found: $HIVE_EXEC_CORE_PATH"
    		m_echo "Downloading $HIVE_EXEC_CORE_URL..."

		TMP_JAR="${HIVE_EXEC_CORE_PATH}.tmp"

    		if ! wget -q -O "$TMP_JAR" "$HIVE_EXEC_CORE_URL" || [[ ! -s "$TMP_JAR" ]]; then
        		rm -f "$TMP_JAR" 2>/dev/null
        		m_exit "Could not download $HIVE_EXEC_CORE_JAR. Please download it manually and copy it to ${FLINK_LIB}"
    		fi

    		if ! mv "$TMP_JAR" "$HIVE_EXEC_CORE_PATH"; then
    			rm -f "$TMP_JAR" 2>/dev/null
        		m_exit "Could not install $HIVE_EXEC_CORE_JAR into $FLINK_LIB"
    		fi
	fi

	if [[ -f "${FLINK_OPT}/${FLINK_SQL_CONNECTOR_HIVE_JAR}" ]]; then
		if ! mv "${FLINK_OPT}/${FLINK_SQL_CONNECTOR_HIVE_JAR}" "$FLINK_LIB/"; then
			m_exit "Could not move $FLINK_SQL_CONNECTOR_HIVE_JAR from $FLINK_OPT to $FLINK_LIB"
    		fi	
	elif [[ ! -f "$FLINK_SQL_CONNECTOR_HIVE_PATH" ]]; then
    		m_echo "Flink SQL connector for Hive not found: $FLINK_SQL_CONNECTOR_HIVE_PATH"
    		m_echo "Downloading $FLINK_SQL_CONNECTOR_HIVE_URL..."

    		TMP_JAR="${FLINK_SQL_CONNECTOR_HIVE_PATH}.tmp"

   		if ! wget -q -O "$TMP_JAR" "$FLINK_SQL_CONNECTOR_HIVE_URL" || [[ ! -s "$TMP_JAR" ]]; then
        		rm -f "$TMP_JAR" 2>/dev/null
        		m_exit "Could not download $FLINK_SQL_CONNECTOR_HIVE_JAR. Please download it manually and copy it to ${FLINK_LIB}"
    		fi

    		if ! mv "$TMP_JAR" "$FLINK_SQL_CONNECTOR_HIVE_PATH"; then
        		rm -f "$TMP_JAR" 2>/dev/null
        		m_exit "Could not install $FLINK_SQL_CONNECTOR_HIVE_JAR into $FLINK_LIB"
    		fi
	fi

	# Remove the isolated loader from lib/ so it stops interfering
	mv "$FLINK_LIB"/flink-table-planner-loader-*.jar "$FLINK_OPT"/ 2>/dev/null || true	

	# Copy the real planner
	if ! find "$FLINK_OPT" -maxdepth 1 -name "flink-table-planner*.jar" ! -name "*loader*" -exec cp {} "$FLINK_LIB/" \;; then
		m_exit "Could not copy Flink table planner JAR to $FLINK_LIB"
	fi

	# Set classpath excluding problematic jars
	for f in "$HIVE_LIB"/*.jar; do
	    [[ -f "$f" ]] || continue
	    
            filename=$(basename "$f")
            
            case "$filename" in
                hive-exec-*.jar|calcite-*|scala-*.jar|spark-*.jar)
                    ;;
                *)
                    HIVE_FILTERED_CLASSPATH="$HIVE_FILTERED_CLASSPATH:$f"
                    ;;
            esac
        done

	export HADOOP_CLASSPATH="$HIVE_FILTERED_CLASSPATH"
else
	if [[ -f "$FLINK_SQL_CONNECTOR_HIVE_PATH" ]]; then
		mv "$FLINK_SQL_CONNECTOR_HIVE_PATH" "$FLINK_OPT/"
	fi
	
	if [[ -f "$HIVE_EXEC_CORE_PATH" ]]; then
		mv "$HIVE_EXEC_CORE_PATH" "$FLINK_OPT/"
	fi
fi
