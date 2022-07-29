#!/bin/sh

export FLAMEMR_WORKLOADS_JAR=${FLAMEMR_HOME}/lib/flamemr-workloads-*.jar
export REDUCERS_NUMBER=$(( ${SLAVES_NUMBER} * ${FLAMEMR_WORKERS_PER_NODE} * ${FLAMEMR_CORES_PER_WORKER} ))


if [[ ( $GEN_KMEANS == "true" || $GEN_BAYES == "true" ) && ! -d $MAHOUT_HOME ]]
then
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

	if [[ $? != 0 ]]
	then
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
