#!/bin/sh

# Set FLINK_CONF_DIR in config.sh
FLINK_CONF_DIR_LINE="export FLINK_CONF_DIR=$FLINK_CONF_DIR"

if grep -q FLINK_CONF_DIR $FLINK_SBIN_DIR/config.sh; then
	
	sed -i "/export FLINK_CONF_DIR/c\\$FLINK_CONF_DIR_LINE" $FLINK_SBIN_DIR/config.sh
else
       	echo $FLINK_CONF_DIR_LINE >> $FLINK_SBIN_DIR/config.sh
fi
