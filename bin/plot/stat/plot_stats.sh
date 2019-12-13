#!/bin/bash

. $STAT_PLOT_HOME/functions.sh
. $STAT_PLOT_HOME/constants.sh


cd ${STATLOGDIR}

GRAPHS_SCRIPT=${STATLOGDIR}/gen_graphs.sh
echo "$SCRIPT_HEADER" > ${GRAPHS_SCRIPT}


CPU_DAT_FILES=""
LOAD_DAT_FILES=""
MEM_DAT_FILES=""
declare -A DSK_DAT_FILES
declare -A DSK_UTIL_DAT_FILES
declare -A NET_DAT_FILES

for STATLOGFILE in `find -name stat.csv`
do
	STATNODEDIR=`dirname $STATLOGFILE`
	rm -f $STATNODEDIR/*.eps $STATNODEDIR/*.dat $STATNODEDIR/*.tmp
	NLINES=`cat $STATLOGFILE | wc -l`
	STAT_CONTENTS=`cat $STATLOGFILE | tail -n $(( $NLINES - 6 ))`

	HEADER=`sed -n '5p' ${STATLOGFILE}`
	SUBHEADER=`sed -n '6p' ${STATLOGFILE}`

	EPOCH_INDEX=`get_index "$EPOCH_TAG" "$HEADER"`
	EPOCHS=`echo "$STAT_CONTENTS" | cut -d "," -f $EPOCH_INDEX`
	NORM_EPOCHS=""
	FIRST_EPOCH=`echo "$EPOCHS" | head -n 1`
	for EPOCH in $EPOCHS
	do
		NORM_EPOCH=`op $EPOCH - $FIRST_EPOCH`
		NORM_EPOCHS="${NORM_EPOCHS}${NORM_EPOCH}\n"
	done
	EPOCHS=`echo -e $NORM_EPOCHS`
	MAX_EPOCH=$( op_int `echo "$EPOCHS" | tail -n 1` )
	
	#CPU

	FILE_PREFIX=$STATNODEDIR/cpu_stat
	TAG="$CPU_TAG"
	NVALUES="$CPU_NVALUES"
	YLABEL=$CPU_YLABEL
	YFORMAT=$CPU_YFORMAT
	declare -A SUB_TAGS=$CPU_DIC
	ini_dat_file
	CPU_DAT_FILES="$CPU_DAT_FILES $DAT_FILE"
	gen_dat_file
	plot_dat_file_lines
	plot_dat_file_stacked
	

	#Load

	FILE_PREFIX=$STATNODEDIR/cpu_load_stat
	TAG="$LOAD_TAG"
	NVALUES="$LOAD_NVALUES"
	YLABEL=$LOAD_YLABEL
	YFORMAT=$LOAD_YFORMAT
	declare -A SUB_TAGS=$LOAD_DIC
	ini_dat_file
	LOAD_DAT_FILES="$LOAD_DAT_FILES $DAT_FILE"
	gen_dat_file
	plot_dat_file_boxes

	#Memory

	FILE_PREFIX=$STATNODEDIR/mem_stat
	TAG="$MEM_TAG"
	NVALUES="$MEM_NVALUES"
	YLABEL=$MEM_YLABEL
	YFORMAT=$MEM_YFORMAT
	declare -A SUB_TAGS=$MEM_DIC
	ini_dat_file
	MEM_DAT_FILES="$MEM_DAT_FILES $DAT_FILE"
	gen_dat_file

	TAG="$MEM_TAG"
	NVALUES="$MEM_NVALUES"
	SUM_TAG="$MEM_FREE_TAG"
	declare -A SUB_TAGS=$MEM_FREE_DIC
	sum_dat_file

	TAG="$SWP_TAG"
	NVALUES="$SWP_NVALUES"
	declare -A SUB_TAGS=$SWP_DIC
	gen_dat_file
	
	OLD_PALETTE_FILE=$PALETTE_FILE
	PALETTE_FILE=$MEM_PALETTE_FILE
	plot_dat_file_lines
	plot_dat_file_stacked
	PALETTE_FILE=$OLD_PALETTE_FILE

	#Disk

	DSK_INDEXES=`get_index $DSK_EXP "$HEADER"`

	for INDEX in $DSK_INDEXES
	do
		DSK_TAG=`get_value $INDEX "$HEADER"`
		DSK_NAME=${DSK_TAG##\"dsk/}
		DSK_NAME=${DSK_NAME%*\"}

		FILE_PREFIX=$STATNODEDIR/dsk_${DSK_NAME}_rw_stat
		TAG="$DSK_TAG"
		NVALUES="$DSK_NVALUES"
		YLABEL=$DSK_YLABEL
		YFORMAT=$DSK_YFORMAT
		## Substitute variable with actual DSK_NAME
		#declare -A SUB_TAGS=$(echo $(eval "echo \"$DSK_DIC\""))
		declare -A SUB_TAGS=$DSK_DIC
		ini_dat_file
		DSK_DAT_FILES["$DSK_NAME"]="${DSK_DAT_FILES[$DSK_NAME]} $DAT_FILE"
		gen_dat_file
		plot_dat_file_lines
		plot_dat_file_stacked

		FILE_PREFIX=$STATNODEDIR/dsk_${DSK_NAME}_util_stat
		TAG="\"$DSK_NAME\""
		NVALUES="$DSK_UTIL_NVALUES"
		YLABEL=$DSK_UTIL_YLABEL
		YFORMAT=$DSK_UTIL_YFORMAT
		## Substitute variable with actual DSK_NAME
		#declare -A SUB_TAGS=$(echo $(eval "echo \"$DSK_UTIL_DIC\""))
		declare -A SUB_TAGS=$DSK_UTIL_DIC
		ini_dat_file
		DSK_UTIL_DAT_FILES["$DSK_NAME"]="${DSK_UTIL_DAT_FILES[$DSK_NAME]} $DAT_FILE"
		gen_dat_file
		plot_dat_file_boxes
	done

	#Network

	NET_INDEXES=`get_index $NET_EXP "$HEADER"`

	for INDEX in $NET_INDEXES
	do
		NET_TAG=`get_value $INDEX "$HEADER"`
		NET_NAME=${NET_TAG##\"net/}
		NET_NAME=${NET_NAME%*\"}

		FILE_PREFIX=$STATNODEDIR/net_${NET_NAME}_stat
		TAG="$NET_TAG"
		NVALUES="$NET_NVALUES"
		YLABEL=$NET_YLABEL
		YFORMAT=$NET_YFORMAT
		declare -A SUB_TAGS=$NET_DIC
		ini_dat_file
		NET_DAT_FILES["$NET_NAME"]="${NET_DAT_FILES[$NET_NAME]} $DAT_FILE"
		gen_dat_file
		plot_dat_file_lines
		plot_dat_file_stacked
	done
done

STAT_AVG_DIR=./avg
rm -rf $STAT_AVG_DIR
mkdir -p $STAT_AVG_DIR

INPUT_DAT_FILES=$CPU_DAT_FILES
FILE_PREFIX=$STAT_AVG_DIR/cpu_stat
YLABEL=$CPU_YLABEL
YFORMAT=$CPU_YFORMAT

avg_dat_file
plot_dat_file_lines
plot_dat_file_stacked


INPUT_DAT_FILES=$LOAD_DAT_FILES
FILE_PREFIX=$STAT_AVG_DIR/load_stat
YLABEL=$LOAD_YLABEL
YFORMAT=$LOAD_YFORMAT

avg_dat_file
plot_dat_file_boxes

INPUT_DAT_FILES=$MEM_DAT_FILES
FILE_PREFIX=$STAT_AVG_DIR/mem_stat
YLABEL=$MEM_YLABEL
YFORMAT=$MEM_YFORMAT

avg_dat_file

OLD_PALETTE_FILE=$PALETTE_FILE
PALETTE_FILE=$MEM_PALETTE_FILE
plot_dat_file_lines
plot_dat_file_stacked
PALETTE_FILE=$OLD_PALETTE_FILE

for DSK_NAME in ${!DSK_DAT_FILES[@]}
do
	# echo $DSK_NAME ${DSK_DAT_FILES[$DSK_NAME]}
	INPUT_DAT_FILES=${DSK_DAT_FILES[$DSK_NAME]}
	FILE_PREFIX=$STAT_AVG_DIR/dsk_${DSK_NAME}_rw_stat
	YLABEL=$DSK_YLABEL
	YFORMAT=$DSK_YFORMAT

	avg_dat_file
	plot_dat_file_lines
	plot_dat_file_stacked

	INPUT_DAT_FILES=${DSK_UTIL_DAT_FILES[$DSK_NAME]}
	FILE_PREFIX=$STAT_AVG_DIR/dsk_${DSK_NAME}_util_stat
	YLABEL=$DSK_UTIL_YLABEL
	YFORMAT=$DSK_UTIL_YFORMAT

	avg_dat_file
	plot_dat_file_boxes
done

for NET_NAME in ${!NET_DAT_FILES[@]}
do
	# echo $NET_NAME ${NET_DAT_FILES[$NET_NAME]}
	INPUT_DAT_FILES=${NET_DAT_FILES[$NET_NAME]}
	FILE_PREFIX=$STAT_AVG_DIR/net_${NET_NAME}_stat
	YLABEL=$NET_YLABEL
	YFORMAT=$NET_YFORMAT

	avg_dat_file
	plot_dat_file_lines
	plot_dat_file_stacked
done

chmod +x ${GRAPHS_SCRIPT}

if [[ ! -f ${REPORT_GEN_GRAPHS_FILE} ]]
then
	echo "$SCRIPT_HEADER" > ${REPORT_GEN_GRAPHS_FILE}
	chmod +x ${REPORT_GEN_GRAPHS_FILE}
fi

echo ".${GRAPHS_SCRIPT#${REPORT_DIR}}" >> ${REPORT_GEN_GRAPHS_FILE}

if [[ $STAT_GEN_GRAPHS == "true" ]]
then
	${GRAPHS_SCRIPT}
fi
