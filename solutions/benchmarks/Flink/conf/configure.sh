#!/bin/sh

export FLINK_BENCH_JAR_NAME=flinkbench-1.10_${FLINK_SCALA_VERSION}.jar
export FLINK_BENCH_DIR=$SOL_BENCH_DIR/bin
export FLINK_BENCH_JAR=$FLINK_BENCH_DIR/$FLINK_BENCH_JAR_NAME
export SORT_PARTITIONS=$FLINK_PARALLELISM

if [[ ! -f $FLINK_BENCH_JAR ]]
then
        # Download flinkbench jar file
        URL=http://bdev.des.udc.es/dist/flinkbench
        m_echo "Downloading $FLINK_BENCH_JAR_NAME"

        wget -q -O $FLINK_BENCH_JAR $URL/$FLINK_BENCH_JAR_NAME

        if [[ $? != 0 ]]
        then
                m_exit "Error when downloading $FLINK_BENCH_JAR_NAME"
        fi
else
	m_echo "Using $FLINK_BENCH_JAR"
fi
