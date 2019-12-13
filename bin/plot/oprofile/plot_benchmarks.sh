#!/bin/bash

OPROFILE_SUMMARY_FILE=$OPROFILE_PLOT_DIR/summary.csv

BENCHMARK_INPUT_FILES=`find $SOLUTION_REPORT_DIR -wholename */${BENCHMARK}_*/sum.csv`

for BENCHMARK_INPUT_FILE in $BENCHMARK_INPUT_FILES
do
	cat $BENCHMARK_INPUT_FILE | sed "s/^/${CLUSTER_SIZE},${SOLUTION},${BENCHMARK},/" >> $OPROFILE_SUMMARY_FILE
done


EVENTS=`cat $OPROFILE_SUMMARY_FILE | cut -f 4 -d "," | sort -u`
CLUSTERS=`echo $CLUSTER_SIZES | wc -w`
STEP=0.9
COLS=`echo $SOLUTIONS | wc -w`
BOX_SIZE=`op "$STEP / $COLS"`
MINX=`op_int "-1 "`
MAXX=`op_int "$CLUSTERS "`
YLABEL="Counter value"


DAT_HEADER="cluster_size"

for SOLUTION in $SOLUTIONS
do
	DAT_HEADER="$DAT_HEADER ${SOLUTION} ${SOLUTION}_MIN ${SOLUTION}_MAX"
done

for EVENT in $EVENTS
do
	EVENT_OUTPUT_DIR=$OPROFILE_PLOT_DIR/${BENCHMARK}
	if [[ ! -d $EVENT_OUTPUT_DIR ]]
	then
		mkdir -p $EVENT_OUTPUT_DIR
	fi
	EVENT_OUTPUT_FILE=$EVENT_OUTPUT_DIR/${EVENT}.dat
	EVENT_PLOT_FILE=$EVENT_OUTPUT_DIR/${EVENT}.eps
	TITLE_TAG="$BENCHMARK_TAG $EVENT"


	echo "$DAT_HEADER" > $EVENT_OUTPUT_FILE

	#cat $OPROFILE_SUMMARY_FILE | grep ",${BENCHMARK},${EVENT}," > $EVENT_OUTPUT_FILE

	EVENT_SUMMARY=`cat $OPROFILE_SUMMARY_FILE | grep ",${BENCHMARK},${EVENT},"`

	for CLUSTER_SIZE in $CLUSTER_SIZES
	do
		OUTPUTLINE=""

		for SOLUTION in $SOLUTIONS
		do
			LINE=`echo "$EVENT_SUMMARY" | egrep "^${CLUSTER_SIZE},${SOLUTION},"`
			EVENT_COUNTERS=`echo "$LINE" | cut -f 5 -d ","`

			median $EVENT_COUNTERS
			maxmin $EVENT_COUNTERS

			if [[ $COUNT -eq 0 ]]
			then
				MEDIAN="?"
				MAX="?"
				MIN="?"
			fi

			OUTPUTLINE="$OUTPUTLINE $MEDIAN $MIN $MAX"
		done
		if [[ -n `echo "$OUTPUTLINE" | tr -d "?" | tr -d " "` ]]
		then
			OUTPUTLINE="$CLUSTER_SIZE$OUTPUTLINE"
			echo "$OUTPUTLINE" >> $EVENT_OUTPUT_FILE
		fi
	done

	gnuplot -e "input_file='$EVENT_OUTPUT_FILE';output_file='$EVENT_PLOT_FILE'; \
		palette_file='$PLOT_HOME/palette.plt'; \
		box_size='$BOX_SIZE'; \
		cols='$COLS'; label_y='$YLABEL'; label_xtics='$CLUSTER_SIZES'; \
		title_tag='$TITLE_TAG'; \
		minx='$MINX';maxx='$MAXX'" $OPROFILE_PLOT_HOME/graph.gplot 
done

