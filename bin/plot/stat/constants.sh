EPOCH_TAG='"epoch"'
EPOCH_HEADER='Epoch'

PALETTE_FILE="$STAT_PLOT_HOME/palette.plt"
export BDEV_HOME=$METHOD_HOME
export SCRIPT_HEADER='#!/bin/bash
dir=`dirname $0`
cd $dir 

if [ -v $BDEV_HOME ]; then
	echo "BDEV_HOME is not set"
	exit
fi
'

CPU_TAG='"total cpu usage"'
CPU_DIC="( ['\"usr\"']='User' ['\"sys\"']='System' ['\"wai\"']='Wait I/O' )"
CPU_NVALUES=6
CPU_YLABEL="CPU utilization (%)"
CPU_YFORMAT="percent"

LOAD_TAG='"load avg"'
LOAD_DIC="( ['\"1m\"']='Load' )"
LOAD_NVALUES=3
LOAD_YLABEL="CPU Load (avg #procs)"
LOAD_YFORMAT=""

MEM_TAG='"memory usage"'
MEM_DIC="( ['\"used\"']='Used' ['\"cach\"']='Cached' )"
MEM_NVALUES=4
MEM_YLABEL="Memory utilization"
MEM_YFORMAT="bytes"
MEM_PALETTE_FILE=$STAT_PLOT_HOME/palette_mem.plt

SWP_TAG='"swap"'
SWP_DIC="( ['\"used\"']='Swapped' )"
SWP_NVALUES=2

MEM_FREE_TAG="Free"
MEM_FREE_DIC="( ['\"buff\"']='Buffered' ['\"free\"']='Free' )"

DSK_EXP='"dsk/*"'
#DSK_DIC='( ["\\\"dsk/${DSK_NAME}:read\\\""]="Read" ["\\\"dsk/${DSK_NAME}:writ\\\""]="Write" )'
DSK_DIC="( ['\"read\"']='Read' ['\"writ\"']='Write' )"
DSK_NVALUES=2
DSK_YLABEL="Disk traffic"
DSK_YFORMAT="bytes"

#DSK_UTIL_DIC='( ["\\\"${DSK_NAME}:util\\\""]="Util" )'
DSK_UTIL_DIC="( ['\"util\"']='Util' )"
DSK_UTIL_NVALUES=1
DSK_UTIL_YLABEL="Disk utilization (%)"
DSK_UTIL_YFORMAT="percent"

NET_EXP='"net/*"'
NET_DIC="( ['\"recv\"']='Recv' ['\"send\"']='Send' )"
NET_NVALUES=2
NET_YLABEL="Network traffic"
NET_YFORMAT="bytes"
