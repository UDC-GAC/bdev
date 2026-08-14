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
		wget -q -O ${HIVE_LIB}/$COMMONS_COLLECTIONS_JAR https://bdev.des.udc.es/dist/$COMMONS_COLLECTIONS_JAR
	fi
}

export PEGASUS_JAR=$THIRD_PARTY_DIR/pegasus-2.0/pegasus-2.0.jar
export HIVE_HOME=$THIRD_PARTY_DIR/hive-$HIVE_VERSION

if [[ ( $GEN_KMEANS == "true" || $GEN_BAYES == "true" ) && ! -d $MAHOUT_HOME ]]; then
	URL="https://archive.apache.org/dist/mahout"

	# Download Mahout 0.11.x and 0.12.0 compiled for Hadoop 1 from bdev
	if [[ $MAHOUT_HOME == $THIRD_PARTY_DIR/mahout-$MAHOUT_VERSION-hadoop ]]; then
		if [[ $MAHOUT_VERSION=0.11.1 || $MAHOUT_VERSION=0.11.2 || $MAHOUT_VERSION=0.12.0 ]]; then
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

	# Manage Hive issues (Guava, commons-collections)
	resolve_hive_issues
fi

if [[ "$GEN_TPCX_HS" == "true" ]]; then
	export HADOOP_BENCH_DIR=$SOL_BENCH_DIR/bin
	export HADOOP_TPCX_HS_JAR_NAME=tpcx-hs-hadoop.jar
	export TPCX_HS_JAR=$HADOOP_BENCH_DIR/${HADOOP_TPCX_HS_JAR_NAME}

	if [ ! -f $TPCX_HS_JAR ]; then
		# Download TPCx-HS jar file
		URL=https://bdev.des.udc.es/dist/tpcx-hs
		m_echo "Downloading $HADOOP_TPCX_HS_JAR_NAME from $URL"

    	wget -q -O $TPCX_HS_JAR $URL/$HADOOP_TPCX_HS_JAR_NAME

    	if [ $? != 0 ]; then
			rm $TPCX_HS_JAR >& /dev/null
			m_exit "Error when downloading $HADOOP_TPCX_HS_JAR_NAME"
    	fi
	else
		m_echo "Using $TPCX_HS_JAR"
	fi
fi
