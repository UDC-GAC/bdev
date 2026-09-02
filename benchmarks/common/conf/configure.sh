#!/bin/bash

function resolve_hive_issues() {
    local HIVE_LIB="${HIVE_HOME}/lib"
    local HADOOP_LIB="${HADOOP_HOME}/share/hadoop/common/lib"
    local BACKUP_FILE=$(ls ${HIVE_LIB}/guava-*-original.bak 2>/dev/null | head -n 1)
    local COMMONS_COLLECTIONS_JAR=commons-collections-3.2.2.jar
	
    if [[ -z "${BACKUP_FILE}" ]]; then
        local ORIGINAL_JAR=$(ls ${HIVE_LIB}/guava-*.jar 2>/dev/null | grep -v 'original.bak' | head -n 1)
        
        if [[ -z "${ORIGINAL_JAR}" ]]; then
            m_exit "No guava.jar was found in $HIVE_LIB"
        fi
        
        mv "${ORIGINAL_JAR}" "${ORIGINAL_JAR}-original.bak"
        BACKUP_FILE="${ORIGINAL_JAR}-original.bak"
    fi

    rm -f ${HIVE_LIB}/guava-*.jar

    if [[ "${HADOOP_SERIES}" == 3 ]]; then
        cp ${HADOOP_LIB}/guava-*.jar ${HIVE_LIB}/
    else
        local RESTORED_JAR="${BACKUP_FILE%-original.bak}"
        cp "${BACKUP_FILE}" "${RESTORED_JAR}"
    fi

	if [[ ! -f ${HIVE_LIB}/$COMMONS_COLLECTIONS_JAR ]]; then
		URL=https://bdev.des.udc.es/dist
		m_echo "Downloading $COMMONS_COLLECTIONS_JAR from $URL"
		wget -q -O ${HIVE_LIB}/$COMMONS_COLLECTIONS_JAR $URL/$COMMONS_COLLECTIONS_JAR

		if [[ $? != 0 ]]; then
			rm ${HIVE_LIB}/$COMMONS_COLLECTIONS_JAR >& /dev/null
			m_exit "Error when downloading $COMMONS_COLLECTIONS_JAR"
    		fi
	fi
}

# Load storage backend functions
. ${COMMON_SRC_DIR}/lib/storage_backend.sh

export JAVA_HOME=${BDEV_JAVA_HOME}
export DATAGEN_JAR=${COMMON_BENCH_DIR}/bin/rgen.jar
export HADOOP_EXAMPLES_JAR=$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples*.jar
export REDUCERS_NUMBER=$(( ${SLAVES_NUMBER} * ${REDUCERS_PER_NODE} ))
export MAPPERS_NUMBER=$(( ${SLAVES_NUMBER} * ${MAPPERS_PER_NODE} ))
export TPCX_HS_ROWS_NUMBER=$(( $TPCX_HS_DATASIZE / 100 ))
export TERASORT_ROWS_NUMBER=$(( $TERASORT_DATASIZE / 100 ))

export HADOOP_EXECUTABLE="$HADOOP_HOME/bin/hadoop"
export YARN_EXECUTABLE="$HADOOP_HOME/bin/yarn"
export HDFS_CONFIG="$HADOOP_HOME/bin/hdfs --config"
export YARN_CONFIG="$YARN_EXECUTABLE --config"

if [[ -f "$HADOOP_EXECUTABLE" ]]; then
	if [[ ! -x "$HADOOP_EXECUTABLE" ]]; then
    		m_exit "Hadoop command is not executable: $HADOOP_EXECUTABLE"
	fi

	export HADOOP_CLASSPATH=$($HADOOP_EXECUTABLE classpath)
fi
if [[ -f "$YARN_EXECUTABLE" ]]; then
        if [[ ! -x "$YARN_EXECUTABLE" ]]; then
                m_exit "YARN command is not executable: $YARN_EXECUTABLE"
        fi
fi

export CONFIG_REDUCER_NUMBER="mapreduce.job.reduces"
export CONFIG_MAP_NUMBER="mapreduce.job.maps"
export CONFIG_RANDOMTEXTWRITER_TOTALBYTES="mapreduce.randomtextwriter.totalbytes"
export CONFIG_RANDOMTEXTWRITER_BYTESPERMAP="mapreduce.randomtextwriter.bytespermap"
export CONFIG_RANDOMTEXTWRITER_MAPSPERHOST="mapreduce.randomtextwriter.mapsperhost"
export TEXT_INPUT_FORMAT="org.apache.hadoop.mapreduce.lib.input.TextInputFormat"
export KEY_VALUE_TEXT_INPUT_FORMAT="org.apache.hadoop.mapreduce.lib.input.KeyValueTextInputFormat"
export SEQUENCE_FILE_INPUT_FORMAT="org.apache.hadoop.mapreduce.lib.input.SequenceFileInputFormat"
export TEXT_OUTPUT_FORMAT="org.apache.hadoop.mapreduce.lib.output.TextOutputFormat"
export SEQUENCE_FILE_OUTPUT_FORMAT="org.apache.hadoop.mapreduce.lib.output.SequenceFileOutputFormat"
export MAHOUT_VERSION=$HADOOP_MAHOUT_VERSION
export MAHOUT_HOME=$THIRD_PARTY_DIR/mahout-$MAHOUT_VERSION-hadoop-yarn
export HIVE_VERSION=$HADOOP_HIVE_VERSION
export HIVE_HOME=$THIRD_PARTY_DIR/hive-$HIVE_VERSION

if [[ "x$EXAMPLES_DATA_FORMAT" == "xSequence" ]]; then
	export EXAMPLES_INPUT_FORMAT=$SEQUENCE_FILE_INPUT_FORMAT
	export EXAMPLES_OUTPUT_FORMAT=$SEQUENCE_FILE_OUTPUT_FORMAT
elif [[ "x$EXAMPLES_DATA_FORMAT" == "xKeyValueText" ]]; then
	export EXAMPLES_INPUT_FORMAT=$KEY_VALUE_TEXT_INPUT_FORMAT
	export EXAMPLES_OUTPUT_FORMAT=$TEXT_OUTPUT_FORMAT
elif [[ "x$EXAMPLES_DATA_FORMAT" == "xText" ]]; then
	export EXAMPLES_INPUT_FORMAT=$TEXT_INPUT_FORMAT
	export EXAMPLES_OUTPUT_FORMAT=$TEXT_OUTPUT_FORMAT
else 
	m_err "Unknown examples format $EXAMPLES_DATA_FORMAT"
fi

export RGEN_BASE_PATH="${STORAGE_BACKEND_URI}/RGen"
export INPUT_WORDCOUNT="${STORAGE_BACKEND_URI}/Input/WordCount"
export INPUT_SORT="${STORAGE_BACKEND_URI}/Input/Sort"
export INPUT_GREP="${STORAGE_BACKEND_URI}/Input/Grep"
export INPUT_TERASORT="${STORAGE_BACKEND_URI}/Input/TeraSort"
export INPUT_TPCX_HS="${STORAGE_BACKEND_URI}/Input/TPCx-HS"
export INPUT_PAGERANK="${STORAGE_BACKEND_URI}/Input/PageRank"
export INPUT_CC="${STORAGE_BACKEND_URI}/Input/ConnectedComponents"
export INPUT_KMEANS="${STORAGE_BACKEND_URI}/Input/KMeans"
export INPUT_BAYES="${STORAGE_BACKEND_URI}/Input/Bayes"
export INPUT_AGGREGATION="${STORAGE_BACKEND_URI}/Input/Aggregation"
export INPUT_JOIN="${STORAGE_BACKEND_URI}/Input/Join"
export INPUT_SCAN="${STORAGE_BACKEND_URI}/Input/Scan"

export OUTPUT_WORDCOUNT="${STORAGE_BACKEND_URI}/Output/WordCount"
export OUTPUT_SORT="${STORAGE_BACKEND_URI}/Output/Sort"
export OUTPUT_GREP="${STORAGE_BACKEND_URI}/Output/Grep"
export OUTPUT_TERASORT="${STORAGE_BACKEND_URI}/Output/TeraSort"
export OUTPUT_TPCX_HS="${STORAGE_BACKEND_URI}/Output/TPCx-HS"
export OUTPUT_PAGERANK="${STORAGE_BACKEND_URI}/Output/PageRank"
export OUTPUT_CC="${STORAGE_BACKEND_URI}/Output/ConnectedComponents"
export OUTPUT_KMEANS="${STORAGE_BACKEND_URI}/Output/KMeans"
export OUTPUT_BAYES="${STORAGE_BACKEND_URI}/Output/Bayes"
export OUTPUT_AGGREGATION="${STORAGE_BACKEND_URI}/Output/Aggregation"
export OUTPUT_JOIN="${STORAGE_BACKEND_URI}/Output/Join"
export OUTPUT_SCAN="${STORAGE_BACKEND_URI}/Output/Scan"

export GEN_WORDCOUNT=false
export GEN_SORT=false
export GEN_GREP=false
export GEN_TERASORT=false
export GEN_TPCX_HS=false
export GEN_CC=false
export GEN_PAGERANK=false
export GEN_KMEANS=false
export GEN_BAYES=false
export GEN_AGGREGATION=false
export GEN_JOIN=false
export GEN_SCAN=false
export GEN_COMMAND=false

for BENCHMARK in $BENCHMARKS
do
    case "$BENCHMARK" in
    	testdfsio)             ;;
        terasort)              GEN_TERASORT=true ;;
        wordcount)             GEN_WORDCOUNT=true ;;
        sort)                  GEN_SORT=true ;;
        grep)                  GEN_GREP=true ;;
        tpcx_hs)               GEN_TPCX_HS=true ;;
        pagerank)              GEN_PAGERANK=true ;;
        connected_components)  GEN_CC=true ;;
        kmeans)                GEN_KMEANS=true ;;
        bayes)                 GEN_BAYES=true ;;
        aggregation)           GEN_AGGREGATION=true ;;
        join)                  GEN_JOIN=true ;;
        scan)                  GEN_SCAN=true ;;
        command)               GEN_COMMAND=true ;;
        *)
            m_exit "Unknown benchmark: $BENCHMARK"
            ;;
    esac
done

# Hive download
if [[ ( $GEN_AGGREGATION == "true" || $GEN_JOIN == "true" || $GEN_SCAN == "true" ) ]]; then
	if [[ "${HIVE_VERSION}" == 4.* ]]; then
		m_exit "Hive 4.x is not supported: $HIVE_VERSION"
	fi
	
	if [[ ! -d $HIVE_HOME ]]; then
		URL="https://archive.apache.org/dist/hive/"
		TMP_HIVE_FILE=$THIRD_PARTY_DIR/apache-hive-${HIVE_VERSION}-bin.tar.gz
		TMP_HIVE_DIR=$THIRD_PARTY_DIR/apache-hive-${HIVE_VERSION}-bin

		m_echo "Downloading hive-$HIVE_VERSION"
		wget -q -O $TMP_HIVE_FILE $URL/hive-$HIVE_VERSION/apache-hive-${HIVE_VERSION}-bin.tar.gz

		if [[ $? != 0 ]]; then
			rm $TMP_HIVE_FILE >& /dev/null
			TMP_HIVE_FILE=$THIRD_PARTY_DIR/hive-${HIVE_VERSION}-bin.tar.gz
			TMP_HIVE_DIR=$THIRD_PARTY_DIR/hive-${HIVE_VERSION}-bin
			wget -q -O $TMP_HIVE_FILE $URL/hive-$HIVE_VERSION/hive-${HIVE_VERSION}-bin.tar.gz
			
			if [[ $? != 0 ]]; then
				rm $TMP_HIVE_FILE >& /dev/null
				m_exit "Error when downloading hive-$HIVE_VERSION"
    			fi
		fi

		m_echo "Extracting $TMP_HIVE_FILE"
		tar -xzf $TMP_HIVE_FILE -C $THIRD_PARTY_DIR
		mv $TMP_HIVE_DIR $HIVE_HOME
		rm $TMP_HIVE_FILE >& /dev/null
	fi

	# Manage Hive issues (Guava, commons-collections)
	resolve_hive_issues
fi

# Hive SQL queries adapted from HiBench
function prepare_sql () {
    unset HIVE_OPTS
    unset HADOOP_CLIENT_OPTS
	
	export HIVE_TMP_DIR=/hive/tmp
	export HADOOP_CLIENT_OPTS="-Djavax.jdo.option.ConnectionURL=jdbc:derby:${BENCHMARK_OUTPUT_DIR}/metastore_db;create=true"
	export HIVE_OPTS="--hiveconf hive.execution.engine=mr \
		--hiveconf javax.jdo.option.ConnectionURL='jdbc:derby:${BENCHMARK_OUTPUT_DIR}/metastore_db;create=true' \
        --hiveconf hive.exec.scratchdir=${HIVE_TMP_DIR} \
        --hiveconf hive.exec.local.scratchdir=${TMP_DIR}/hive \
        --hiveconf hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat \
        --hiveconf hive.stats.autogather=false \
        --hiveconf derby.stream.error.file=${BENCHMARK_OUTPUT_DIR}/derby.log \
        --hiveconf hive.log.dir=${TMP_DIR}/hive \
        --hiveconf $CONFIG_MAP_NUMBER=$MAPPERS_NUMBER \
        --hiveconf $CONFIG_REDUCER_NUMBER=$REDUCERS_NUMBER"

    export HIVE_OPTS="${HIVE_OPTS//$'\n'/ }"
    export HIVE_OPTS="${HIVE_OPTS//$'\t'/ }"

    rm -rf ${BENCHMARK_OUTPUT_DIR}/metastore_db
}

export -f prepare_sql

function init_hive_metastore () {
	mkdir -p ${BENCHMARK_OUTPUT_DIR}

	${HIVE_HOME}/bin/schematool \
        -dbType derby \
        -initSchema \
        -url "jdbc:derby:${BENCHMARK_OUTPUT_DIR}/metastore_db;create=true" \
        -userName APP \
        -passWord mine 2>&1 | grep -v '^[[:space:]]*$'
}

export -f init_hive_metastore

function prepare_sql_aggregation () {
	prepare_sql
	HIVE_SQL_FILE=$1

	cat <<EOF > ${HIVE_SQL_FILE}
USE DEFAULT;

CREATE EXTERNAL TABLE uservisits_aggre_input (sourceIP STRING,destURL STRING,visitDate STRING,adRevenue DOUBLE,userAgent STRING,countryCode STRING,languageCode STRING,searchWord STRING,duration INT ) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' STORED AS SEQUENCEFILE LOCATION '$INPUT_AGGREGATION/uservisits';
CREATE EXTERNAL TABLE uservisits_aggre (sourceIP STRING,sumAdRevenue DOUBLE) STORED AS SEQUENCEFILE LOCATION '$OUTPUT_AGGREGATION/uservisits_aggre';
INSERT OVERWRITE TABLE uservisits_aggre SELECT sourceIP, SUM(adRevenue) FROM uservisits_aggre_input GROUP BY sourceIP;
EOF
}

export -f prepare_sql_aggregation

function prepare_sql_join () {
	prepare_sql
	HIVE_SQL_FILE=$1

	cat <<EOF > ${HIVE_SQL_FILE}
USE DEFAULT;
SET hive.auto.convert.join = false;

CREATE EXTERNAL TABLE rankings_join_input (pageURL STRING, pageRank INT, avgDuration INT) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' STORED AS SEQUENCEFILE LOCATION '$INPUT_JOIN/rankings';
CREATE EXTERNAL TABLE uservisits_join_input (sourceIP STRING,destURL STRING,visitDate STRING,adRevenue DOUBLE,userAgent STRING,countryCode STRING,languageCode STRING,searchWord STRING,duration INT ) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' STORED AS SEQUENCEFILE LOCATION '$INPUT_JOIN/uservisits';
CREATE EXTERNAL TABLE rankings_uservisits_join (sourceIP STRING, avgPageRank DOUBLE, totalRevenue DOUBLE) STORED AS SEQUENCEFILE LOCATION '$OUTPUT_JOIN/rankings_uservisits_join';
INSERT OVERWRITE TABLE rankings_uservisits_join SELECT sourceIP, avg(pageRank), sum(adRevenue) as totalRevenue FROM rankings_join_input R JOIN (SELECT sourceIP, destURL, adRevenue FROM uservisits_join_input UV WHERE (datediff(UV.visitDate, '1999-01-01')>=0 AND datediff(UV.visitDate, '2000-01-01')<=0)) NUV ON (R.pageURL = NUV.destURL) group by sourceIP order by totalRevenue DESC;
EOF
}

export -f prepare_sql_join

function prepare_sql_scan () {
	prepare_sql
	HIVE_SQL_FILE=$1

	cat <<EOF > ${HIVE_SQL_FILE}
USE DEFAULT;

CREATE EXTERNAL TABLE uservisits_scan_input (sourceIP STRING,destURL STRING,visitDate STRING,adRevenue DOUBLE,userAgent STRING,countryCode STRING,languageCode STRING,searchWord STRING,duration INT ) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' STORED AS SEQUENCEFILE LOCATION '$INPUT_SCAN/uservisits';
CREATE EXTERNAL TABLE uservisits_scan (sourceIP STRING,destURL STRING,visitDate STRING,adRevenue DOUBLE,userAgent STRING,countryCode STRING,languageCode STRING,searchWord STRING,duration INT ) ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde' STORED AS SEQUENCEFILE LOCATION '$OUTPUT_SCAN/uservisits_scan';
INSERT OVERWRITE TABLE uservisits_scan SELECT * FROM uservisits_scan_input;
EOF
}

export -f prepare_sql_scan
