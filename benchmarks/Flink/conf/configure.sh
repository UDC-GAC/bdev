#!/bin/bash

install_dependency_jar() {
    local jar_name="$1"
    local url="$2"
    local desc="$3"
    local target_dest="$FLINK_LIB_DIR/$jar_name"
    
    # Remove any existing link or file at the destination
    rm -f "$target_dest" 2>/dev/null

    # If it exists in the tarball's opt/ directory, we link from there
    if [[ -f "$FLINK_TARBALL_OPT/$jar_name" ]]; then
        ln -sf "$FLINK_TARBALL_OPT/$jar_name" "$target_dest"
    else
        # If it comes from the BDEv cache, we copy it to the report dir to ensure visibility across all remote nodes
        local cached_jar="$BDEV_LIB_DIR/$jar_name"
        download_jar_if_missing "$cached_jar" "$url" "$desc"
        cp -f "$cached_jar" "$target_dest"
    fi
}

# Variables
# Hardcode last scala version supported by Flink 1.x
# From Flink 2.x onwards, Flink is scala-free
FLINK_SCALA_VERSION=2.12
FLINK_TARBALL_LIB="$FLINK_HOME/lib"
FLINK_TARBALL_OPT="$FLINK_HOME/opt"
export SORT_PARTITIONS="$FLINK_PARALLELISM"
export FLINK_HIVE_VERSION="3.1.3"
	
if [[ "$FLINK_MAJOR_VERSION" == "1.15" || "$FLINK_MAJOR_VERSION" == "1.16" ]]; then
	export FLINK_HIVE_VERSION="3.1.2"
fi

# Determine whether integration with Hive is required
is_hive="false"
if [[ "$GEN_AGGREGATION" == "true" || "$GEN_JOIN" == "true" || "$GEN_SCAN" == "true" ]]; then
    is_hive="true"
fi

# Project Flink base libraries while respecting the Table Planner
for jar in "$FLINK_TARBALL_LIB"/*.jar; do
    [[ -f "$jar" ]] || continue
    jar_name="${jar##*/}"

    # If we use Hive, we skip the isolated loader to avoid conflicts.
    if [[ "$is_hive" == "true" && "$jar_name" == flink-table-planner-loader-* ]]; then
        continue
    fi
    ln -sf "$jar" "$FLINK_LIB_DIR/"
done

# Hadoop MapReduce dependencies
MAPREDUCE_JAR_FILE=("$HADOOP_HOME"/share/hadoop/mapreduce/hadoop-mapreduce-client-core-*.jar)

if [[ ! -f "${MAPREDUCE_JAR_FILE[0]}" ]]; then
    m_exit "MapReduce jar not found: $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-client-core-*.jar"
fi

ln -sf "${MAPREDUCE_JAR_FILE[0]}" "$FLINK_LIB_DIR/"

# Flink Hadoop compatibility
FLINK_HADOOP_COMPATIBILITY_JAR="flink-hadoop-compatibility_${FLINK_SCALA_VERSION}-${FLINK_VERSION}.jar"
FLINK_HADOOP_COMPATIBILITY_URL="https://repo1.maven.org/maven2/org/apache/flink/flink-hadoop-compatibility_${FLINK_SCALA_VERSION}/${FLINK_VERSION}/${FLINK_HADOOP_COMPATIBILITY_JAR}"
install_dependency_jar "$FLINK_HADOOP_COMPATIBILITY_JAR" "$FLINK_HADOOP_COMPATIBILITY_URL" "Flink Hadoop compatibility JAR"

# FlinkBench JAR
FLINK_BENCH_JAR_NAME="flinkbench-1.0_${FLINK_SCALA_VERSION}.jar"
export FLINK_BENCH_JAR="$BDEV_LIB_DIR/$FLINK_BENCH_JAR_NAME"
download_jar_if_missing "$FLINK_BENCH_JAR" "$BDEV_WEBPAGE/dist/flinkbench/$FLINK_BENCH_JAR_NAME" "$FLINK_BENCH_JAR_NAME"
m_echo "Using $FLINK_BENCH_JAR"
    
# TPCx-HS Benchmark JAR
if [[ "$GEN_TPCX_HS" == "true" ]]; then
    if [[ "$FLINK_SERIES" != "1" ]]; then
        m_exit "Flink version is not supported for TPCx-HS: $FLINK_VERSION"
    fi

    FLINK_TPCX_HS_JAR_NAME="tpcx-hs-flink-1.0_${FLINK_SCALA_VERSION}.jar"
    export TPCX_HS_JAR="$BDEV_LIB_DIR/$FLINK_TPCX_HS_JAR_NAME"
    download_jar_if_missing "$TPCX_HS_JAR" \
        "$BDEV_WEBPAGE/dist/tpcx-hs/$FLINK_TPCX_HS_JAR_NAME" \
        "$FLINK_TPCX_HS_JAR_NAME"
    m_echo "Using $TPCX_HS_JAR"
fi

# Hive-specific configuration
if [[ "$is_hive" == "true" ]]; then
	if [[ -z "$HIVE_HOME" ]]; then
		m_exit "HIVE_HOME is not defined or is empty"
	fi

	if [[ ! -d "$HIVE_HOME" ]]; then
		m_exit "HIVE_HOME does not exist or is not a directory: $HIVE_HOME"
	fi
	
	# Install Hive Exec Core
	HIVE_LIB="${HIVE_HOME}/lib"
	HIVE_EXEC_CORE_JAR="hive-exec-${FLINK_HIVE_VERSION}-core.jar"
	HIVE_EXEC_CORE_URL="https://repo1.maven.org/maven2/org/apache/hive/hive-exec/${FLINK_HIVE_VERSION}/${HIVE_EXEC_CORE_JAR}"
	install_dependency_jar "$HIVE_EXEC_CORE_JAR" "$HIVE_EXEC_CORE_URL" "Hive exec core jar"

	# Install SQL Connector
	FLINK_SQL_CONNECTOR_HIVE_JAR="flink-connector-hive_${FLINK_SCALA_VERSION}-${FLINK_VERSION}.jar"
	FLINK_SQL_CONNECTOR_HIVE_URL="https://repo1.maven.org/maven2/org/apache/flink/flink-connector-hive_${FLINK_SCALA_VERSION}/${FLINK_VERSION}/${FLINK_SQL_CONNECTOR_HIVE_JAR}"
	install_dependency_jar "$FLINK_SQL_CONNECTOR_HIVE_JAR" "$FLINK_SQL_CONNECTOR_HIVE_URL" "Flink SQL connector for Hive"

	# Link the actual Table Planner from opt/
	planner_found="false"
	for planner in "$FLINK_TARBALL_OPT"/flink-table-planner*.jar; do
		[[ -f "$planner" ]] || continue
		[[ "$planner" == *loader* ]] && continue
		ln -sf "$planner" "$FLINK_LIB_DIR/"
		planner_found="true"
	done

	if [[ "$planner_found" == "false" ]]; then
		m_exit "Could not find Flink table planner JAR in $FLINK_TARBALL_OPT"
	fi

	# Set classpath excluding problematic jars
	HIVE_FILTERED_CLASSPATH=""
	for f in "$HIVE_LIB"/*.jar; do
	    [[ -f "$f" ]] || continue
	    
            filename="${f##*/}"
            
            case "$filename" in
                hive-exec-*.jar|calcite-*|scala-*.jar|spark-*.jar)
			;;
                *)
			HIVE_FILTERED_CLASSPATH="${HIVE_FILTERED_CLASSPATH:+${HIVE_FILTERED_CLASSPATH}:}$f"
			;;
            esac
        done

	export HADOOP_CLASSPATH="$HIVE_FILTERED_CLASSPATH:${HADOOP_CLASSPATH:-}"
fi
