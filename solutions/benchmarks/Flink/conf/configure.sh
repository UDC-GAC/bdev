#!/bin/sh

export SORT_PARTITIONS=$FLINK_PARALLELISM

if [[ $FLINK_MAJOR_VERSION == "1.10" || $FLINK_MAJOR_VERSION == "1.11" ]]
then
	export FLINK_BENCH_JAR_NAME=flinkbench-1.10_${FLINK_SCALA_VERSION}.jar
else
	export FLINK_BENCH_JAR_NAME=flinkbench-1.12_${FLINK_SCALA_VERSION}.jar
fi

export FLINK_BENCH_DIR=$SOL_BENCH_DIR/bin
export FLINK_BENCH_JAR=$FLINK_BENCH_DIR/$FLINK_BENCH_JAR_NAME

if [[ ! -f $FLINK_BENCH_JAR ]]
then
        # Download flinkbench jar file
        URL=https://bdev.des.udc.es/dist/flinkbench
        m_echo "Downloading $FLINK_BENCH_JAR_NAME"

        wget -q -O $FLINK_BENCH_JAR $URL/$FLINK_BENCH_JAR_NAME

        if [[ $? != 0 ]]
        then
		rm $FLINK_BENCH_JAR >& /dev/null
                m_exit "Error when downloading $FLINK_BENCH_JAR_NAME"
        fi
else
	m_echo "Using $FLINK_BENCH_JAR"
fi
