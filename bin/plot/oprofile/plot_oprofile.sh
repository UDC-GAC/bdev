#!/bin/bash

. $OPROFILE_PLOT_HOME/functions.sh

PALETTE_FILE="$OPROFILE_PLOT_HOME/palette.plt"

unset OPROFILEINPUTFILES
for INPUT_FILE in  $( find ${OPROFILELOGDIR} -name "oprofile" | xargs -n1 | sort -u | xargs )
do
	if [[ ! $( basename $(dirname $INPUT_FILE ) ) == "node-0" ]]
	then
		OPROFILEINPUTFILES="$OPROFILEINPUTFILES $INPUT_FILE"
	fi
done

FIRST_FILE=`echo $OPROFILEINPUTFILES | cut -f 1 -d " "`

NUM_LINES=`wc -l $FIRST_FILE | cut -f 1 -d " "`

OUTPUT_NODE_SUM_FILE="${OPROFILELOGDIR}/sum.csv"

rm -f $OUTPUT_NODE_SUM_FILE

for i in `seq 1 $NUM_LINES`
do
	ROW_FIRST_FILE=`get_row $i $FIRST_FILE`
	if [[ $ROW_FIRST_FILE == "" ]]
	then
		continue;
	fi

	EVENT=`echo "$ROW_FIRST_FILE" | cut -f 1 -d ","`

	unset VALUE
	unset PERCENT
	VALUE_SUM="0"
	PERCENT_SUM="0"

	for f in $OPROFILEINPUTFILES
	do
		ROW=`get_row $i $f`
		VALUE=`echo "$ROW" | cut -f 2 -d ","`
		PERCENT=`echo "$ROW" | cut -f 3 -d ","`
		VALUE_SUM=`op_int "$VALUE + $VALUE_SUM"`
		PERCENT_SUM=`op "$PERCENT + $PERCENT_SUM"`
	done

	echo "$EVENT,$VALUE_SUM,$PERCENT_SUM" >> $OUTPUT_NODE_SUM_FILE

done



# for OPROFILENODEDIR in $OPROFILENODEDIRS
# do
# 	OUTPUT_NODE_FILE=$OPROFILENODEDIR/oprofile_counters
# 
# 	rm -f $OUTPUT_NODE_FILE
# 
# 	NUM_LINES=`cat ${OPROFILENODEDIR}/oprofile | wc -l`
# 	EVENT_COUNTERS=`cat ${OPROFILENODEDIR}/oprofile | egrep "Event *Count" -A $NUM_LINES | tail -n +2`
# 
# 	#EVENTS=`cat ${OPROFILENODEDIR}/oprofile.out | grep "Monitoring events:" | cut -f 3 -d " " | tr "," "\n"`
# 	#NUM_EVENTS=`echo "$EVENTS" | wc -l`
# 
# 	#for i in `seq 1 $NUM_EVENTS`
# 	#do
# 	#	EVENT=`get_row $i "$EVENTS"`
# 	#	COUNTER=`get_row $i "$EVENT_COUNTERS"`
# 	#	echo $EVENT $COUNTER >> $OUTPUT_NODE_FILE
# 	#done
# 
# 	echo "${EVENT_COUNTERS//,}" | sed -e 's/^[ \t]*//' |  tr -s "\t " "," > $OUTPUT_NODE_FILE
# 
# done


