#!/bin/sh

# Set SPARK_CONF_DIR in spark-config.sh
SPARK_CONF_DIR_LINE="export SPARK_CONF_DIR=$SPARK_CONF_DIR"
sed -i "/export SPARK_CONF_DIR/c\\$SPARK_CONF_DIR_LINE" $SPARK_SBIN_DIR/spark-config.sh
