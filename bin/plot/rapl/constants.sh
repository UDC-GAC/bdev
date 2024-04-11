#!/bin/sh

export PALETTE_FILE="$PLOT_HOME/palette.plt"
export BDEV_HOME=$METHOD_HOME
export SCRIPT_HEADER='#!/bin/bash
dir=`dirname $0`
cd $dir 

if [ -v ${BDEV_HOME} ]; then
	echo "BDEV_HOME is not set"
	exit
fi
'
