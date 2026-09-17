#!/bin/bash


function get_row() {
	sed -n "${1}{p;q}" "$2"
}

export -f get_row

function op_dat_file() {
	AWK_COMMAND="$1"
	
	TARGET_DAT_FILES=""
	for INPUT_FILE in $(printf '%s\n' $INPUT_DAT_FILES | sort -u); do
		if [[ "$(basename "$(dirname "$INPUT_FILE")")" != "node-0" ]]; then
			TARGET_DAT_FILES+=" $INPUT_FILE"
		fi
	done

	OUTPUT_SUM_FILE="${FILE_PREFIX}.csv"
	get_min_rows

	FIRST_DAT_FILE=$(read -r FIRST_DAT_FILE <<< "$TARGET_DAT_FILES")
	NCOLS=$(awk 'NR == 1 { print NF; exit }' "$FIRST_DAT_FILE")
	HEADER=$(head -n 1 "$FIRST_DAT_FILE")
	OUTPUT_FILE_CONTENT=$(get_row 1 "$FIRST_DAT_FILE")
	COL=2

	while [[ "$COL" -le "$NCOLS" ]]; do
		unset ALL_COLUMNS
		for f in $TARGET_DAT_FILES; do
			ALL_COLUMNS=$(paste -d " " <(echo "$ALL_COLUMNS") <(get_row "$COL" "$f"))
		done

		NEW_COLUMN=$(awk "$AWK_COMMAND" <(echo "$ALL_COLUMNS"))
		OUTPUT_FILE_CONTENT=$(paste -d "," <(echo "$OUTPUT_FILE_CONTENT") <(echo "$NEW_COLUMN"))
		COL=$((COL + 1))
	done

	echo "$HEADER" > $OUTPUT_SUM_FILE
	echo "$OUTPUT_FILE_CONTENT" >> $OUTPUT_SUM_FILE
}

export -f op_dat_file

function sum_dat_file() {
	op_dat_file '{x=0;for(i=1;i<=NF;i++)x+=$i;print x}'
}

export -f sum_dat_file


function avg_dat_file() {
	op_dat_file '{x=0;for(i=1;i<=NF;i++)x+=$i;print x/NF}'
}

export -f avg_dat_file

