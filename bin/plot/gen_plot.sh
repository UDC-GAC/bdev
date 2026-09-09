#!/bin/bash

DAT_HEADER="cluster_size"

for FRAMEWORK in $FRAMEWORKS
do
	DAT_HEADER="$DAT_HEADER ${FRAMEWORK} ${FRAMEWORK}_MIN ${FRAMEWORK}_MAX"
done

echo "$DAT_HEADER" > $DAT_FILE

for CLUSTER_SIZE in $CLUSTER_SIZES
do
	OUTPUTLINE=""

	for FRAMEWORK in $FRAMEWORKS
	do
		LINE=`echo "$REPORT_CONTENTS" | grep $FRAMEWORK | grep -E "^\s*$CLUSTER_SIZE"`
		FRAMEWORK_TIMES=`echo "$LINE" | cut -f 4`

		avg $FRAMEWORK_TIMES
		maxmin $FRAMEWORK_TIMES

		if [[ $COUNT -eq 0 ]]
		then
			AVG="?"
			MAX="?"
			MIN="?"
		fi

		OUTPUTLINE="$OUTPUTLINE $AVG $MIN $MAX"
	done
	if [[ -n `echo "$OUTPUTLINE" | tr -d "?" | tr -d " "` ]]
	then
		OUTPUTLINE="$CLUSTER_SIZE$OUTPUTLINE"
		echo "$OUTPUTLINE" >> $DAT_FILE
	fi
done

COLS=`echo $FRAMEWORKS | wc -w`
CLUSTERS=`echo $CLUSTER_SIZES | wc -w`
#BOX_SIZE=0.15
#STEP=`op "$COLS * $BOX_SIZE"`
STEP=0.9
BOX_SIZE=`op "$STEP / $COLS"`
#MINX=`op_int "-$STEP "`
#MAXX=`op_int "$CLUSTERS * $STEP"`
MINX=`op_int "-1 "`
MAXX=`op_int "$CLUSTERS "`

echo gnuplot -e "input_file='$DAT_FILE';output_file='$PLOT_FILE'; \
		palette_file='$PLOT_HOME/palette.plt'; \
		box_size='$BOX_SIZE'; \
		cols='$COLS'; label_y='$YLABEL'; label_xtics='$CLUSTER_SIZES'; \
		benchmark_tag='$BENCHMARK_TAG'; \
		minx='$MINX';maxx='$MAXX'" $PLOT_HOME/graph.gplot 

gnuplot -e "input_file='$DAT_FILE';output_file='$PLOT_FILE'; \
		palette_file='$PLOT_HOME/palette.plt'; \
		box_size='$BOX_SIZE'; \
		cols='$COLS'; label_y='$YLABEL'; label_xtics='$CLUSTER_SIZES'; \
		benchmark_tag='$BENCHMARK_TAG'; \
		minx='$MINX';maxx='$MAXX'" $PLOT_HOME/graph.gplot 
