#!/bin/sh

if [ $# -eq 1 ]; then
	# Set SPARK_CONF_DIR in spark-config.sh
	SPARK_CONF_DIR_LINE="export SPARK_CONF_DIR=$SPARK_CONF_DIR"

	if grep -q SPARK_CONF_DIR $SPARK_SBIN_DIR/spark-config.sh; then

        	sed -i "/export SPARK_CONF_DIR/c\\$SPARK_CONF_DIR_LINE" $SPARK_SBIN_DIR/spark-config.sh
	else
        	echo $SPARK_CONF_DIR_LINE >> $SPARK_SBIN_DIR/spark-config.sh
	fi

	# Set SPARK_LOCAL_IP in spark-config.sh
	SPARK_LOCAL_IP_LINE=`cat $SPARK_CONF_DIR/spark-local-ip-env.sh`

	if grep -q SPARK_LOCAL_IP $SPARK_SBIN_DIR/spark-config.sh; then

        	sed -i "/export SPARK_LOCAL_IP/c\\$SPARK_LOCAL_IP_LINE" $SPARK_SBIN_DIR/spark-config.sh
	else
        	echo $SPARK_LOCAL_IP_LINE >> $SPARK_SBIN_DIR/spark-config.sh
	fi
else
	# Remove SPARK_LOCAL_IP from spark-config.sh (original file does not include this variable)
	if grep -q SPARK_LOCAL_IP $SPARK_SBIN_DIR/spark-config.sh; then
        	sed -i '/export SPARK_LOCAL_IP/d' $SPARK_SBIN_DIR/spark-config.sh
	fi
fi
