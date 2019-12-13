#!/bin/sh

function get_index(){
	# echo "$1"
	# echo "${2}"
	SEARCH_WORD=$1
	IFS=',' read -a ARRAY <<< "${2}"

	INDEX=1
	FOUND_INDEXES=""
	for WORD in "${ARRAY[@]}"
	{
		WORD_DEV=`echo $WORD | cut -f 2 -d ":" | tr -d "\""`
		SEARCH_WORD_DEV=`echo $SEARCH_WORD | cut -f 2 -d ":" | tr -d "\""`
		#echo "$WORD $SEARCH_WORD $WORD_DEV $SEARCH_WORD_DEV" 1>&2
		if [[  $WORD == $SEARCH_WORD || $WORD_DEV == $SEARCH_WORD_DEV ]]
		then
			FOUND_INDEXES="$FOUND_INDEXES $INDEX"
		fi
		INDEX=$(( $INDEX + 1 ))
	}
	echo $FOUND_INDEXES
	# for ((i = 0; i < ${#ARRAY[@]}; i++))
	# do
	# 	WORD="${ARRAY[$i]}"
	# 	echo $WORD
	# done
}

export -f get_index

function get_value(){
	NUM=$1
	STRING=$2
	echo "$STRING" \
	|  tr -s " " | sed -e 's/^[ \t]*//' \
	| cut -d "," -f $NUM
}

export -f get_value


function ini_dat_file(){
	DAT_FILE=${FILE_PREFIX}.dat
	TMP_DAT_FILE=${FILE_PREFIX}.tmp
	SUM_FILE=${FILE_PREFIX}_sum.dat
	TMP_SUM_FILE=${FILE_PREFIX}_sum.tmp
	echo "$EPOCH_HEADER" > $DAT_FILE
	echo "$EPOCHS" >> $DAT_FILE
}

export -f ini_dat_file

function gen_dat_file(){
	TAG_INDEXES=`get_index "$TAG" "$HEADER"`
	for FIRST_INDEX in "$TAG_INDEXES"
	do
		LAST_INDEX=$(( $FIRST_INDEX + $NVALUES - 1 ))
		TAG_SUBHEADER=`echo "$SUBHEADER" | cut -d "," -f $FIRST_INDEX-$LAST_INDEX`

		for SUB_TAG in ${!SUB_TAGS[@]}
		do
			TMP_FILE=$STATNODEDIR/$(echo ${SUB_TAG}.tmp | tr "/:" "_")
			SUB_TAG_INDEX=`get_index "$SUB_TAG" "$TAG_SUBHEADER"`
			if [[ -z $SUB_TAG_INDEX ]]
			then
				echo "Not found subtag ${SUB_TAG} of tag ${TAG} in $TAG_SUBHEADER"
				continue;
			fi
			TAG_SUB_INDEX=$(( $FIRST_INDEX + $SUB_TAG_INDEX - 1 ))
			echo "${SUB_TAGS[$SUB_TAG]}" > $TMP_FILE
			echo "$STAT_CONTENTS" | cut -d "," -f $TAG_SUB_INDEX >> $TMP_FILE
			paste -d "," $DAT_FILE $TMP_FILE > $TMP_DAT_FILE
			mv $TMP_DAT_FILE $DAT_FILE
			rm $TMP_FILE
		done
	done
}

export -f gen_dat_file

function sum_files() {
	touch $1
	touch $2
	paste -d " " $1 $2 | awk '{printf( "%f\n", ($1 + $2))}' > $3
}

export -f sum_files

function div_file() {
	cat $1 | awk "{printf(\"%f\n\", (\$1 / $2) )}" > $3
}

export -f div_file

function avg_file_rows() {
	cat $1 | awk '{s=0; for(i=1; i<=NF; i++){s+=$i}; s/=NF; printf("%f\n", s)}' > $2
}

export -f avg_file_rows

# function avg_file_cols() {
# }

# export -f avg_file_cols

function sum_dat_file() {
	TAG_INDEXES=`get_index "$TAG" "$HEADER"`
	TMP_FILES=""
	for FIRST_INDEX in "$TAG_INDEXES"
	do
		LAST_INDEX=$(( $FIRST_INDEX + $NVALUES - 1 ))
		TAG_SUBHEADER=`echo "$SUBHEADER" | cut -d "," -f $FIRST_INDEX-$LAST_INDEX`

		for SUB_TAG in ${!SUB_TAGS[@]}
		do
			TMP_FILE=$STATNODEDIR/${SUB_TAG}.tmp
			SUB_TAG_INDEX=`get_index "$SUB_TAG" "$TAG_SUBHEADER"`
			TAG_SUB_INDEX=$(( $FIRST_INDEX + $SUB_TAG_INDEX - 1 ))
			echo "$STAT_CONTENTS" | cut -d "," -f $TAG_SUB_INDEX > $TMP_FILE
			TMP_FILES="$TMP_FILES $TMP_FILE"
		done
	done
	rm -f $SUM_FILE
	for TMP_FILE in $TMP_FILES
	do
		if [[ ! -f "$SUM_FILE" ]]
		then
			cat $TMP_FILE > $SUM_FILE
			continue
		fi
		paste -d " " $SUM_FILE $TMP_FILE | awk '{print ($1 + $2)}' > $TMP_SUM_FILE
		mv $TMP_SUM_FILE $SUM_FILE
	done
	echo "$SUM_TAG" > $TMP_SUM_FILE
	cat $SUM_FILE >> $TMP_SUM_FILE
	mv $TMP_SUM_FILE $SUM_FILE

	paste -d "," $DAT_FILE $SUM_FILE > $TMP_DAT_FILE
	mv $TMP_DAT_FILE $DAT_FILE
	rm $TMP_FILES $SUM_FILE
}

export -f sum_dat_file

function avg_dat_file() {
	TARGET_DAT_FILES=""
	for INPUT_FILE in  $( echo $INPUT_DAT_FILES | xargs -n1 | sort -u | xargs )
	do
		if [[ ! $( basename $(dirname $INPUT_FILE ) ) == "node-0" ]]
		then
			TARGET_DAT_FILES="$TARGET_DAT_FILES $INPUT_FILE"
		fi
	done
	# echo $TARGET_DAT_FILES
	DAT_FILE=${FILE_PREFIX}.dat
	SUM_DAT_FILE=${FILE_PREFIX}_sum.dat
	TMP_SUM_DAT_FILE=${FILE_PREFIX}_sum.tmp
	AVG_DAT_FILE=${FILE_PREFIX}_avg.dat
	TMP_AVG_DAT_FILE=${FILE_PREFIX}_avg.tmp
	TMP_DAT_FILE=${FILE_PREFIX}_tmp.tmp

	FIRST_FILE=`echo $TARGET_DAT_FILES | cut -d " " -f 1`
	FIRST_HEAD=`cat $FIRST_FILE | head -n 1`

	NFILES=$(( `echo $TARGET_DAT_FILES | wc -w` ))
	NCOLS=$(( `echo $FIRST_HEAD | grep -o "," | wc -l` + 1 ))

	for COL in `seq 1 $NCOLS`
	do
		TMP_FILE=${FILE_PREFIX}_${COL}.tmp
		JOIN_FILE=${FILE_PREFIX}_${COL}_join.tmp
		TMP_JOIN_FILE=${FILE_PREFIX}_${COL}_tmp_join.tmp
		AVG_FILE=${FILE_PREFIX}_${COL}_avg.tmp
		TMP_AVG_FILE=${FILE_PREFIX}_${COL}_tmp_avg.tmp
		AVG_AVG_FILE=${FILE_PREFIX}_${COL}_avg_avg.tmp
		SUM_AVG_FILE=${FILE_PREFIX}_${COL}_avg_sum.tmp

		touch $JOIN_FILE
		COL_TAG=`head -n 1 $FIRST_FILE | cut -d "," -f $COL`
		for F in $TARGET_DAT_FILES
		do
			tail -n+2 $F | cut -d "," -f $COL > $TMP_FILE
			paste -d " " $JOIN_FILE $TMP_FILE > $TMP_JOIN_FILE
			mv $TMP_JOIN_FILE $JOIN_FILE
		done

		avg_file_rows $JOIN_FILE $TMP_AVG_FILE

		echo "$COL_TAG" > $AVG_FILE
		cat $TMP_AVG_FILE >> $AVG_FILE


		if [[ ! -f $DAT_FILE ]]
		then
			mv $AVG_FILE $DAT_FILE
		else
			paste -d "," $DAT_FILE $AVG_FILE > $TMP_DAT_FILE
			mv $TMP_DAT_FILE $DAT_FILE
		fi

		AVG_VALUES=`cat $TMP_AVG_FILE`
		
		rm -f $TMP_FILE $JOIN_FILE $TMP_JOIN_FILE $AVG_FILE $TMP_AVG_FILE 

		if [[ "$COL_TAG" == "$EPOCH_HEADER" ]]
		then
			continue
		fi

		avg $AVG_VALUES
		echo "$COL_TAG" > $AVG_AVG_FILE
		echo $AVG >> $AVG_AVG_FILE

		if [[ ! -f $AVG_DAT_FILE ]]
		then
			mv $AVG_AVG_FILE $AVG_DAT_FILE
		else
			paste -d "," $AVG_DAT_FILE $AVG_AVG_FILE > $TMP_AVG_DAT_FILE
			mv $TMP_AVG_DAT_FILE $AVG_DAT_FILE
		fi

		echo "$COL_TAG" > $SUM_AVG_FILE
		echo $SUM >> $SUM_AVG_FILE
		if [[ ! -f $SUM_DAT_FILE ]]
		then
			mv $SUM_AVG_FILE $SUM_DAT_FILE
		else
			paste -d "," $SUM_DAT_FILE $SUM_AVG_FILE > $TMP_SUM_DAT_FILE
			mv $TMP_SUM_DAT_FILE $SUM_DAT_FILE
		fi
		rm -f $AVG_AVG_FILE $SUM_AVG_FILE
	done
}

export -f avg_dat_file

function plot_dat_file_lines(){
	PLOT_FILE=${FILE_PREFIX}.eps
	DAT_HEAD=`head -n 1 $DAT_FILE`
	COLS=`echo $DAT_HEAD | grep -o "," | wc -l`
	MAX_EPOCH=`tail -n 1 $DAT_FILE | cut -d "," -f 1`
	# echo $MAX_EPOCH
	TICS_INTERVAL=`op_int $MAX_EPOCH / 300 \* 60`
	if [[ "x$TICS_INTERVAL" == "x0" ]]
	then
		TICS_INTERVAL=30
	fi
	echo gnuplot -e "\"input_file='$DAT_FILE';output_file='$PLOT_FILE'; \
		tic_interval=$TICS_INTERVAL; max_x='$MAX_EPOCH'; \
		label_y='$YLABEL'; format_y='$YFORMAT'; \
		palette_file='\${BDEV_HOME}${PALETTE_FILE#$METHOD_HOME}'; \
		cols='$COLS'\"" '${BDEV_HOME}'${STAT_PLOT_HOME#$METHOD_HOME}/lines_graph.gplot >> $GRAPHS_SCRIPT
}

export -f plot_dat_file_lines

function plot_dat_file_boxes(){
	PLOT_FILE=${FILE_PREFIX}.eps
	DAT_HEAD=`head -n 1 $DAT_FILE`
	COLS=`echo $DAT_HEAD | grep -o "," | wc -l`
	MAX_EPOCH=`tail -n 1 $DAT_FILE | cut -d "," -f 1`
	# echo $MAX_EPOCH
	TICS_INTERVAL=`op_int $MAX_EPOCH / 300 \* 60`
	if [[ "x$TICS_INTERVAL" == "x0" ]]
	then
		TICS_INTERVAL=30
	fi
	echo gnuplot -e "\"input_file='$DAT_FILE';output_file='$PLOT_FILE'; \
		tic_interval=$TICS_INTERVAL; max_x='$MAX_EPOCH'; \
		label_y='$YLABEL'; format_y='$YFORMAT'; \
		palette_file='\${BDEV_HOME}${PALETTE_FILE#$METHOD_HOME}'; \
		cols='$COLS'\"" '${BDEV_HOME}'${STAT_PLOT_HOME#$METHOD_HOME}/boxes_graph.gplot >> $GRAPHS_SCRIPT
}

export -f plot_dat_file_boxes

function plot_dat_file_stacked(){
	STOCKED_PLOT_FILE=${FILE_PREFIX}_stacked.eps
	# if [[ -z $STATIC_COLS ]]
	# then
	# 	STATIC_COLS=0
	# fi
	DAT_HEAD=`head -n 1 $DAT_FILE`
	COLS=`echo $DAT_HEAD | grep -o "," | wc -l`
	# STOCKED_COLS=$(( $COLS - $STATIC_COLS ))
	MAX_EPOCH=`tail -n 1 $DAT_FILE | cut -d "," -f 1`
	# echo $MAX_EPOCH
	TICS_INTERVAL=`op_int $MAX_EPOCH / 300 \* 60`
	if [[ "x$TICS_INTERVAL" == "x0" ]]
	then
		TICS_INTERVAL=30
	fi
	echo gnuplot -e "\"input_file='$DAT_FILE';output_file='$STOCKED_PLOT_FILE'; \
		tic_interval=$TICS_INTERVAL; max_x='$MAX_EPOCH'; \
		label_y='$YLABEL'; format_y='$YFORMAT'; \
		palette_file='\${BDEV_HOME}${PALETTE_FILE#$METHOD_HOME}'; \
		cols='$COLS'; \"" '${BDEV_HOME}'${STAT_PLOT_HOME#$METHOD_HOME}/stacked_graph.gplot >> $GRAPHS_SCRIPT
}

export -f plot_dat_file_stacked

