#!/bin/sh
m_echo "Flink daemons"
. $OLD_COPY_DAEMONS_SCRIPT

SOL_SGE_DAEMONS_DIR=$HADOOP_SGE_DAEMONS_DIR
SOL_STD_DAEMONS_DIR=$HADOOP_STD_DAEMONS_DIR
SOL_SBIN_DIR=$HADOOP_SBIN_DIR

m_echo "Hadoop daemons"
. $OLD_COPY_DAEMONS_SCRIPT
