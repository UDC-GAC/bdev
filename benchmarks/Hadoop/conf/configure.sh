#!/bin/bash

export PEGASUS_JAR="$BDEV_LIB_DIR/pegasus-2.0.jar"

if [[ ( $GEN_KMEANS == "true" || $GEN_BAYES == "true" ) && ! -d $MAHOUT_HOME ]]; then
	URL="https://archive.apache.org/dist/mahout"

	# Download Mahout 0.11.x and 0.12.x from bdev website
	if [[ $MAHOUT_VERSION=0.11.1 || $MAHOUT_VERSION=0.11.2 || $MAHOUT_VERSION=0.12.0 || $MAHOUT_VERSION=0.12.2 ]]; then
		URL="$BDEV_WEBPAGE/dist/mahout"
	fi

	TMP_MAHOUT_FILE=$THIRD_PARTY_DIR/apache-mahout-distribution-${MAHOUT_VERSION}.tar.gz
	TMP_MAHOUT_DIR=$THIRD_PARTY_DIR/apache-mahout-distribution-${MAHOUT_VERSION}

	m_echo "Downloading mahout-$MAHOUT_VERSION"
	wget -q -O $TMP_MAHOUT_FILE $URL/$MAHOUT_VERSION/apache-mahout-distribution-${MAHOUT_VERSION}.tar.gz

	if [[ $? != 0 ]]; then
		rm -f $TMP_MAHOUT_FILE >& /dev/null
		TMP_MAHOUT_FILE=$THIRD_PARTY_DIR/mahout-distribution-${MAHOUT_VERSION}.tar.gz
		TMP_MAHOUT_DIR=$THIRD_PARTY_DIR/mahout-distribution-${MAHOUT_VERSION}
		wget -q -O $TMP_MAHOUT_FILE $URL/$MAHOUT_VERSION/mahout-distribution-${MAHOUT_VERSION}.tar.gz
		
		if [[ $? != 0 ]]; then
			rm -f $TMP_MAHOUT_FILE >& /dev/null
			m_exit "Error when downloading mahout-$MAHOUT_VERSION"
    		fi
	fi

	m_echo "Extracting $TMP_MAHOUT_FILE"
	tar -xzf $TMP_MAHOUT_FILE -C $THIRD_PARTY_DIR
	mv $TMP_MAHOUT_DIR $MAHOUT_HOME
	rm -f $TMP_MAHOUT_FILE >& /dev/null
fi

# TPCx-HS Benchmark JAR
if [[ "$GEN_TPCX_HS" == "true" ]]; then
	HADOOP_TPCX_HS_JAR_NAME=tpcx-hs-hadoop.jar
	export TPCX_HS_JAR=$BDEV_LIB_DIR/$HADOOP_TPCX_HS_JAR_NAME
	download_jar_if_missing "$TPCX_HS_JAR" \
		"$BDEV_WEBPAGE/dist/tpcx-hs/$HADOOP_TPCX_HS_JAR_NAME" \
		"$HADOOP_TPCX_HS_JAR_NAME"
    m_echo "Using $TPCX_HS_JAR"
fi
