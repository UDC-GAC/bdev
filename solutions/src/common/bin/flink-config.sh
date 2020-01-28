#!/bin/sh

# Set FLINK_CONF_DIR in config.sh
FLINK_CONF_DIR_LINE="export FLINK_CONF_DIR=$FLINK_CONF_DIR"
sed -i "/export FLINK_CONF_DIR/c\\$FLINK_CONF_DIR_LINE" $FLINK_SBIN_DIR/config.sh
