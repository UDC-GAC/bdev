#!/bin/sh


function get_row(){
	cat "$2" | head -n $1 | tail -n 1
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
}

export -f sum_dat_file


function avg_dat_file(){
	op_dat_file '{x=0;for(i=1;i<=NF;i++)x+=$i;print x/NF}'
}

export -f avg_dat_file

