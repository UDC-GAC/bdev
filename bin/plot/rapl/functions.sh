#!/bin/bash

function get_column_data() {
	# Un solo comando: extrae la columna $1 desde la fila 2 hasta MIN_ROWS
	awk -F',' -v col="$1" -v max="$MIN_ROWS" 'NR > 1 && NR <= max { print $col }' "$2"
}

function get_min_rows() {
	unset MIN_ROWS
	for f in $TARGET_DAT_FILES; do
		local ROWS=$(wc -l < "$f")
		if [[ -z "$MIN_ROWS" || $ROWS -lt $MIN_ROWS ]]; then
			MIN_ROWS=$ROWS
		fi
	done
}

export -f get_min_rows

function op_dat_file() {
	AWK_COMMAND=$1
	
	TARGET_DAT_FILES=""
	for INPUT_FILE in $INPUT_DAT_FILES; do
		local dir="${INPUT_FILE%/*}"	# Equivalente a dirname
		local node="${dir##*/}"		# Equivalente a basename
		if [[ "$node" != "node-0" && -f "$INPUT_FILE" ]]; then
			TARGET_DAT_FILES="${TARGET_DAT_FILES:+$TARGET_DAT_FILES }$INPUT_FILE"
		fi
	done

	[[ -z "$TARGET_DAT_FILES" ]] && return 0

	OUTPUT_SUM_FILE=${FILE_PREFIX}.csv
	get_min_rows

	FIRST_DAT_FILE="${TARGET_DAT_FILES%% *}"
	# Aseguramos el separador por comas para contar columnas fiablemente
	NCOLS=$(awk -F',' '{print NF; exit}' "$FIRST_DAT_FILE")
	HEADER=$(head -n 1 "$FIRST_DAT_FILE")
	OUTPUT_FILE_CONTENT=$(get_column_data 1 "$FIRST_DAT_FILE")
	local COL=2

	while (( COL <= NCOLS )); do
		local ALL_COLUMNS=""
		for f in $TARGET_DAT_FILES; do
			local col_data
			col_data=$(get_column_data $COL "$f")
			if [[ -z "$ALL_COLUMNS" ]]; then
				ALL_COLUMNS="$col_data"
			else
				ALL_COLUMNS=$(paste -d " " <(echo "$ALL_COLUMNS") <(echo "$col_data"))
			fi
		done

		local NEW_COLUMN
		NEW_COLUMN=$(awk "$AWK_COMMAND" <<< "$ALL_COLUMNS")
		OUTPUT_FILE_CONTENT=$(paste -d "," <(echo "$OUTPUT_FILE_CONTENT") <(echo "$NEW_COLUMN"))
		((COL++))
	done

	echo "$HEADER" > "$OUTPUT_SUM_FILE"
	echo "$OUTPUT_FILE_CONTENT" >> "$OUTPUT_SUM_FILE"
}

export -f op_dat_file

function sum_dat_file() {
	op_dat_file '{x=0;for(i=1;i<=NF;i++)x+=$i;print x}'

	if [[ "$VALID_WORKLOAD_RUNTIME" == false ]]; then
		return 0
	fi
    
	awk -F ',' "\$1 <= $WORKLOAD_RUNTIME {for(i=2;i<=NF;i++)sum+=\$i; next} END {print sum}" <(echo "$OUTPUT_FILE_CONTENT") > $OUTPUT_TOT_SUM_FILE
}

function avg_dat_file() {
	op_dat_file '{x=0;for(i=1;i<=NF;i++)x+=$i;print (NF>0 ? x/NF : 0)}'
}

function plot_dat_file_lines() {
	# Evitamos que ls falle con error si la métrica no existe en ese nodo
	DAT_FILES=$(ls ${FILE_PREFIX}*.csv 2>/dev/null)
	[[ -z "$DAT_FILES" ]] && return 0

	PLOT_FILE=${FILE_PREFIX}.eps
	unset COLS

	local LAST_F=""
	for F in $DAT_FILES; do
		local DAT_HEAD=$(head -n 1 "$F")
		# Conteo de comas en memoria sin lanzar echo | grep | wc
		local commas="${DAT_HEAD//[^,]/}"
		COLS="${COLS:+$COLS }${#commas}"
		LAST_F="$F"
	done

	# Extracción del primer campo de la última fila sin llamar a cut
	local LAST_LINE=$(tail -n 1 "$LAST_F")
	MAX_EPOCH="${LAST_LINE%%,*}"

	TICS_INTERVAL=$(op_int $MAX_EPOCH / 300 \* 60)
	if [[ -z "$TICS_INTERVAL" || "$TICS_INTERVAL" == "0" ]]; then
		TICS_INTERVAL=30
	fi

	echo $GNUPLOT_BIN -e "\"input_files='$DAT_FILES';output_file='$PLOT_FILE'; \
	tic_interval=$TICS_INTERVAL; max_x='$MAX_EPOCH'; \
	label_y='$YLABEL'; format_y='$YFORMAT'; \
	palette_file='$PALETTE_FILE'; \
	cols='$COLS'\"" $RAPL_PLOT_HOME/lines_graph.gplot >> $GRAPHS_SCRIPT
}
