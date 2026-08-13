#!/bin/bash

export PEGASUS_JAR=$THIRD_PARTY_DIR/pegasus-2.0/pegasus-2.0.jar
export HIVE_HOME=$THIRD_PARTY_DIR/hive-$HIVE_VERSION

if [[ ( $GEN_KMEANS == "true" || $GEN_BAYES == "true" ) && ! -d $MAHOUT_HOME ]]; then
	URL="https://archive.apache.org/dist/mahout"

	# Download Mahout 0.11.1 and 0.12.0 compiled for Hadoop 1 from bdev
	if [[ $MAHOUT_HOME == $THIRD_PARTY_DIR/mahout-$MAHOUT_VERSION-hadoop ]]
	then
		if [[ $MAHOUT_VERSION=0.11.1 || $MAHOUT_VERSION=0.12.0 ]]
		then
			URL="https://bdev.des.udc.es/dist/mahout"
		else
			m_exit "Mahout version $MAHOUT_VERSION not found"
		fi
	fi

	TMP_MAHOUT_FILE=$THIRD_PARTY_DIR/apache-mahout-distribution-${MAHOUT_VERSION}.tar.gz
	TMP_MAHOUT_DIR=$THIRD_PARTY_DIR/apache-mahout-distribution-${MAHOUT_VERSION}

	m_echo "Downloading mahout-$MAHOUT_VERSION"
	wget -q -O $TMP_MAHOUT_FILE $URL/$MAHOUT_VERSION/apache-mahout-distribution-${MAHOUT_VERSION}.tar.gz

	if [[ $? != 0 ]]; then
		rm $TMP_MAHOUT_FILE
		TMP_MAHOUT_FILE=$THIRD_PARTY_DIR/mahout-distribution-${MAHOUT_VERSION}.tar.gz
		TMP_MAHOUT_DIR=$THIRD_PARTY_DIR/mahout-distribution-${MAHOUT_VERSION}
		wget -q -O $TMP_MAHOUT_FILE $URL/$MAHOUT_VERSION/mahout-distribution-${MAHOUT_VERSION}.tar.gz
	fi

	m_echo "Extracting $TMP_MAHOUT_FILE"
	tar -xzf $TMP_MAHOUT_FILE -C $THIRD_PARTY_DIR
	mv $TMP_MAHOUT_DIR $MAHOUT_HOME
	rm $TMP_MAHOUT_FILE
fi

if [[ ( $GEN_AGGREGATION == "true" || $GEN_JOIN == "true" || $GEN_SCAN == "true" ) && ! -d $HIVE_HOME ]]; then
	URL="https://archive.apache.org/dist/hive/"
	TMP_HIVE_FILE=$THIRD_PARTY_DIR/apache-hive-${HIVE_VERSION}-bin.tar.gz
	TMP_HIVE_DIR=$THIRD_PARTY_DIR/apache-hive-${HIVE_VERSION}-bin

	m_echo "Downloading hive-$HIVE_VERSION"
	wget -q -O $TMP_HIVE_FILE $URL/hive-$HIVE_VERSION/apache-hive-${HIVE_VERSION}-bin.tar.gz

	if [[ $? != 0 ]]; then
		rm $TMP_HIVE_FILE
		TMP_HIVE_FILE=$THIRD_PARTY_DIR/hive-${HIVE_VERSION}-bin.tar.gz
		TMP_HIVE_DIR=$THIRD_PARTY_DIR/hive-${HIVE_VERSION}-bin
		wget -q -O $TMP_HIVE_FILE $URL/hive-$HIVE_VERSION/hive-${HIVE_VERSION}-bin.tar.gz
	fi

	m_echo "Extracting $TMP_HIVE_FILE"
	tar -xzf $TMP_HIVE_FILE -C $THIRD_PARTY_DIR
	mv $TMP_HIVE_DIR $HIVE_HOME
	rm $TMP_HIVE_FILE
fi

if [[ "$BENCHMARK" == "tpcx_hs" ]]; then
	export HADOOP_BENCH_DIR=$SOL_BENCH_DIR/bin
	export HADOOP_TPCX_HS_JAR_NAME=tpcx-hs-hadoop.jar
	export TPCX_HS_JAR=$HADOOP_BENCH_DIR/${HADOOP_TPCX_HS_JAR_NAME}

	# Download TPCx-HS jar file
	URL=https://bdev.des.udc.es/dist/tpcx-hs
	m_echo "Downloading $HADOOP_TCPX_HS_JAR_NAME from $URL"

    wget -q -O $TPCX_HS_JAR $URL/$HADOOP_TCPX_HS_JAR_NAME

    if [ $? != 0 ]; then
		rm $TPCX_HS_JAR >& /dev/null
		m_exit "Error when downloading $HADOOP_TCPX_HS_JAR_NAME"
    fi
else
	m_echo "Using $TPCX_HS_JAR"
fi
