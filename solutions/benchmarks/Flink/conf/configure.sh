#!/bin/sh

export FLINK_BENCH_JAR_NAME=flinkbench-1.8_${FLINK_SCALA_VERSION}.jar
export FLINK_BENCH_JAR=$SOL_BENCH_DIR/bin/$FLINK_BENCH_JAR_NAME
export SORT_PARTITIONS=$FLINK_PARALLELISM

if [[ ! -f $FLINK_BENCH_JAR ]]
then
        # Download flinkbench jar file
        URL="http://bdev.des.udc.es/dist/flinkbench"
        m_echo "Downloading $FLINK_BENCH_JAR_NAME"

        wget -q -O $FLINK_BENCH_JAR $URL/$FLINK_BENCH_JAR_NAME

        if [[ $? != 0 ]]
        then
                m_exit "Error when downloading $FLINK_BENCH_JAR_NAME"
        fi
fi
