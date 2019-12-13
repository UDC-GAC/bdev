#!/bin/sh

function plot_dat_file_lines(){
	DAT_FILES=`ls ${FILE_PREFIX}*.csv`
	PLOT_FILE=${FILE_PREFIX}.eps
	unset COLS
	for F in $DAT_FILES
	do
	DAT_HEAD=`head -n 1 $F`
	C=`echo $DAT_HEAD | grep -o "," | wc -l`
	COLS="$COLS $C"
	done
	MAX_EPOCH=`tail -n 1 $F | cut -d "," -f 1`
	# echo $MAX_EPOCH
	TICS_INTERVAL=`op_int $MAX_EPOCH / 300 \* 60`
	if [[ "x$TICS_INTERVAL" == "x0" ]]
	then
	TICS_INTERVAL=30
	fi
	echo gnuplot -e "\"input_files='$DAT_FILES';output_file='$PLOT_FILE'; \
	tic_interval=$TICS_INTERVAL; max_x='$MAX_EPOCH'; \
	label_y='$YLABEL'; format_y='$YFORMAT'; \
	palette_file='\${BDEV_HOME}${PALETTE_FILE#$METHOD_HOME}'; \
	cols='$COLS'\"" '${BDEV_HOME}'${RAPL_PLOT_HOME#$METHOD_HOME}/lines_graph.gplot >> $GRAPHS_SCRIPT
}

export -f plot_dat_file_lines

function get_min_rows(){
	unset MIN_ROWS
	for f in $TARGET_DAT_FILES
	do
		ROWS=`wc -l $f | cut -f 1 -d " "`
		if [[ $MIN_ROWS == "" || $ROWS -lt $MIN_ROWS ]]
		then
			MIN_ROWS=$ROWS
		fi
	done
}

export -f get_min_rows

function get_row(){
	cut -f $1 -d "," $2 | head -$MIN_ROWS | tail -n +2 
}

export -f get_row

function op_dat_file(){
	AWK_COMMAND=$1
	
	TARGET_DAT_FILES=""
	for INPUT_FILE in  $( echo $INPUT_DAT_FILES | xargs -n1 | sort -u | xargs )
	do
		if [[ ! $( basename $(dirname $INPUT_FILE ) ) == "node-0" ]]
		then
			TARGET_DAT_FILES="$TARGET_DAT_FILES $INPUT_FILE"
		fi
	done


	OUTPUT_SUM_FILE=${FILE_PREFIX}.csv
	get_min_rows

	FIRST_DAT_FILE=`echo $TARGET_DAT_FILES | cut -f 1 -d " "`
	NCOLS=`awk '{print NF}' $FIRST_DAT_FILE | head -n 1`

	HEADER=`cat $FIRST_DAT_FILE | head -1`
	OUTPUT_FILE_CONTENT=`get_row 1 $FIRST_DAT_FILE`

	for COL in `seq 2 $NCOLS`
	do
		unset ALL_COLUMNS
		for f in $TARGET_DAT_FILES
		do
			ALL_COLUMNS=`paste -d " " <(echo "$ALL_COLUMNS") <(get_row $COL $f)`
		done

		NEW_COLUMN=`awk "$AWK_COMMAND" <(echo "$ALL_COLUMNS")`

		OUTPUT_FILE_CONTENT=`paste -d "," <(echo "$OUTPUT_FILE_CONTENT") <(echo "$NEW_COLUMN")`

	done

	echo "$HEADER" > $OUTPUT_SUM_FILE
	echo "$OUTPUT_FILE_CONTENT" >> $OUTPUT_SUM_FILE
}

export -f op_dat_file

function sum_dat_file(){
	op_dat_file '{x=0;for(i=1;i<=NF;i++)x+=$i;print x}'

	awk -F ',' "\$1 <= $ELAPSED_TIME {for(i=2;i<=NF;i++)sum+=\$i; next} END {print sum}" <(echo "$OUTPUT_FILE_CONTENT") > $OUTPUT_TOT_SUM_FILE

}

export -f sum_dat_file


function avg_dat_file(){
	op_dat_file '{x=0;for(i=1;i<=NF;i++)x+=$i;print x/NF}'
}

export -f avg_dat_file

