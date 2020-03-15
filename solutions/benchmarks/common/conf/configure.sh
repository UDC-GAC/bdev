#!/bin/sh

export HDFS=hdfs://$MASTERNODE:$FS_PORT
export HIBENCH_DATAGEN_JAR=$THIRD_PARTY_DIR/hibench/hibench-datagen-5.0.jar
export REDUCERS_NUMBER=$(( ${SLAVES_NUMBER} * ${REDUCERS_PER_NODE} ))
export MAPPERS_NUMBER=$(( ${SLAVES_NUMBER} * ${MAPPERS_PER_NODE} ))
export TERASORT_ROWS_NUMBER=$(( $TERASORT_DATASIZE / 100 ))
export HADOOP_EXECUTABLE="$HADOOP_HOME/bin/hadoop"
export CHMOD="-chmod -R"
# Next line to be removed when Spark supports iterative ConnCompt
export CC_MAX_ITERATIONS=1024

if [[ "x$HADOOP_MR_VERSION" == "xYARN" ]]
then
	#HADOOP YARN version-dependent variables
	export RMR="-rm -r"
	export MKDIR="-mkdir -p"
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
	export HADOOP_EXAMPLES_JAR=$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples*.jar
	export MAHOUT_VERSION=$HADOOP_2_MAHOUT_VERSION
	export MAHOUT_HOME=$THIRD_PARTY_DIR/mahout-$MAHOUT_VERSION-hadoop-yarn
	export HIVE_VERSION=$HADOOP_2_HIVE_VERSION
else
	#HADOOP 1 version-dependent variables
	export RMR="-rmr"
	export MKDIR="-mkdir"
	export CONFIG_REDUCER_NUMBER="mapred.reduce.tasks"
	export CONFIG_MAP_NUMBER="mapred.map.tasks"
	export CONFIG_RANDOMTEXTWRITER_TOTALBYTES="test.randomtextwrite.total_bytes"
	export CONFIG_RANDOMTEXTWRITER_BYTESPERMAP="test.randomtextwrite.bytes_per_map"
	export CONFIG_RANDOMTEXTWRITER_MAPSPERHOST="test.randomtextwrite.maps_per_host"
	export TEXT_INPUT_FORMAT="org.apache.hadoop.mapred.TextInputFormat"
	export KEY_VALUE_TEXT_INPUT_FORMAT="org.apache.hadoop.mapred.KeyValueTextInputFormat"
	export SEQUENCE_FILE_INPUT_FORMAT="org.apache.hadoop.mapred.SequenceFileInputFormat"
	export TEXT_OUTPUT_FORMAT="org.apache.hadoop.mapred.TextOutputFormat"
	export SEQUENCE_FILE_OUTPUT_FORMAT="org.apache.hadoop.mapred.SequenceFileOutputFormat"
	export HADOOP_EXAMPLES_JAR=$HADOOP_HOME/hadoop-examples*.jar
	export MAHOUT_VERSION=$HADOOP_1_MAHOUT_VERSION
	export MAHOUT_HOME=$THIRD_PARTY_DIR/mahout-$MAHOUT_VERSION-hadoop
	export HIVE_VERSION=$HADOOP_1_HIVE_VERSION
fi

if [[ "x$EXAMPLES_DATA_FORMAT" == "xSequence" ]]
then
	export EXAMPLES_INPUT_FORMAT=$SEQUENCE_FILE_INPUT_FORMAT
	export EXAMPLES_OUTPUT_FORMAT=$SEQUENCE_FILE_OUTPUT_FORMAT
elif [[ "x$EXAMPLES_DATA_FORMAT" == "xKeyValueText" ]] 
then
	export EXAMPLES_INPUT_FORMAT=$KEY_VALUE_TEXT_INPUT_FORMAT
	export EXAMPLES_OUTPUT_FORMAT=$TEXT_OUTPUT_FORMAT
elif [[ "x$EXAMPLES_DATA_FORMAT" == "xText" ]] 
then
	export EXAMPLES_INPUT_FORMAT=$TEXT_INPUT_FORMAT
	export EXAMPLES_OUTPUT_FORMAT=$TEXT_OUTPUT_FORMAT
else 
	m_err "Unknown examples format $EXAMPLES_DATA_FORMAT"
fi

export INPUT_WORDCOUNT="${HDFS}/Input/WordCount"
export INPUT_SORT="${HDFS}/Input/Sort"
export INPUT_GREP="${HDFS}/Input/Grep"
export INPUT_TERASORT="${HDFS}/Input/TeraSort"
export INPUT_PAGERANK="${HDFS}/Input/PageRank"
export INPUT_CC="${HDFS}/Input/ConnectedComponents"
export INPUT_KMEANS="${HDFS}/Input/KMeans"
export INPUT_BAYES="${HDFS}/Input/Bayes"
export INPUT_AGGREGATION="${HDFS}/Input/Aggregation"
export INPUT_JOIN="${HDFS}/Input/Join"
export INPUT_SCAN="${HDFS}/Input/Scan"

export OUTPUT_WORDCOUNT="${HDFS}/Output/WordCount"
export OUTPUT_SORT="${HDFS}/Output/Sort"
export OUTPUT_GREP="${HDFS}/Output/Grep"
export OUTPUT_TERASORT="${HDFS}/Output/TeraSort"
export OUTPUT_PAGERANK="${HDFS}/Output/PageRank"
export OUTPUT_CC="${HDFS}/Output/ConnectedComponents"
export OUTPUT_KMEANS="${HDFS}/Output/KMeans"
export OUTPUT_BAYES="${HDFS}/Output/Bayes"
export OUTPUT_AGGREGATION="${HDFS}/Output/Aggregation"
export OUTPUT_JOIN="${HDFS}/Output/Join"
export OUTPUT_SCAN="${HDFS}/Output/Scan"

export GEN_WORDCOUNT="false"
export GEN_SORT="false"
export GEN_TERASORT="false"
export GEN_GREP="false"
export GEN_CC="false"
export GEN_PAGERANK="false"
export GEN_KMEANS="false"
export GEN_BAYES="false"
export GEN_AGGREGATION="false"
export GEN_JOIN="false"
export GEN_SCAN="false"
export GEN_COMMAND="false"

for BENCHMARK in $BENCHMARKS
do
	if [ "$BENCHMARK" == "terasort" ]
	then
		export GEN_TERASORT="true"
	elif [[ "$BENCHMARK" == "wordcount" ]]
	then
		export GEN_WORDCOUNT="true"
	elif [[ "$BENCHMARK" == "sort" ]]
	then
		export GEN_SORT="true"
	elif [[ "$BENCHMARK" == "grep" ]]
	then
		export GEN_GREP="true"
	elif [[ "$BENCHMARK" == "pagerank" ]]
	then
		export GEN_PAGERANK="true"
	elif [[ "$BENCHMARK" == "connected_components" ]]
	then
		export GEN_CC="true"
	elif [[ "$BENCHMARK" == "kmeans" ]]
	then
		export GEN_KMEANS="true"
	elif [[ "$BENCHMARK" == "bayes" ]]
	then
		export GEN_BAYES="true"
	elif [[ "$BENCHMARK" == "aggregation" ]]
	then
		export GEN_AGGREGATION="true"
	elif [[ "$BENCHMARK" == "join" ]]
	then
		export GEN_JOIN="true"
	elif [[ "$BENCHMARK" == "scan" ]]
	then
		export GEN_SCAN="true"
	elif [[ "$BENCHMARK" == "command" ]]
	then
		export GEN_COMMAND="true"
	fi
done

# Hive SQL queries adapted from HiBench

function prepare_sql () {
# hive.exec.scratchdir is an HDFS path
unset  HIVE_OPTS
export HIVE_OPTS="--hiveconf javax.jdo.option.ConnectionURL=jdbc:derby:;databaseName=${BENCHMARK_OUTPUT_DIR}/metastore_db;create=true \
	--hiveconf hive.exec.scratchdir=${HIVE_TMP_DIR} \
	--hiveconf hive.exec.local.scratchdir=${TMP_DIR}/hive \
	--hiveconf hive.input.format=org.apache.hadoop.hive.ql.io.HiveInputFormat \
	--hiveconf hive.stats.autogather=false  \
	--hiveconf derby.stream.error.file=${BENCHMARK_OUTPUT_DIR}/derby.log \
        --hiveconf hive.log.dir=${TMP_DIR}/hive \
        --hiveconf $CONFIG_MAP_NUMBER=$MAPPERS_NUMBER \
        --hiveconf $CONFIG_REDUCER_NUMBER=$REDUCERS_NUMBER"
}

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

