#!/bin/bash

function get_index() {
	local search_word="$1"
	local search_clean="${search_word//\"/}"
	local search_dev
	if [[ "$search_clean" == *:* ]]; then
		search_dev="${search_clean#*:}"
	else
		search_dev="$search_clean"
	fi

	local -a array
	IFS=',' read -r -a array <<< "$2"

	local index=1
	local found=""
	for word in "${array[@]}"; do
		local word_clean="${word//\"/}"
		local word_dev
		if [[ "$word_clean" == *:* ]]; then
			word_dev="${word_clean#*:}"
		else
			word_dev="$word_clean"
		fi

		# Sin comillas en $search_word y $search_dev para respetar el globbing de "dsk/* y "net/*
		if [[ $word == $search_word || $word_dev == $search_dev ]]; then
			found="$found $index"
		fi
		((index++))
	done
	echo $found
}

function get_value() {
	local num="$1"
	local string="$2"
	# Reemplazo de echo | tr | sed | cut por un único awk en memoria
	awk -F',' -v col="$num" '{
		sub(/^[ \t]+/, "", $0);
		gsub(/ +/, " ", $0);
		print $col
	}' <<< "$string"
}

function ini_dat_file() {
	DAT_FILE="${FILE_PREFIX}.dat"
	TMP_DAT_FILE="${FILE_PREFIX}.tmp"
	SUM_FILE="${FILE_PREFIX}_sum.dat"
	TMP_SUM_FILE="${FILE_PREFIX}_sum.tmp"
	echo "$EPOCH_HEADER" > "$DAT_FILE"
	echo "$EPOCHS" >> "$DAT_FILE"
}

function gen_dat_file() {
	local tag_indexes
	tag_indexes=$(get_index "$TAG" "$HEADER")

	local -a col_indices=()
	local -a col_headers=()

	# Recolección de índices en memoria: cero accesos a disco
	for first_index in $tag_indexes; do
		local last_index=$(( first_index + NVALUES - 1 ))
		local tag_subheader
		tag_subheader=$(cut -d "," -f "${first_index}-${last_index}" <<< "$SUBHEADER")

		for sub_tag in "${!SUB_TAGS[@]}"; do
			local sub_tag_index
			sub_tag_index=$(get_index "$sub_tag" "$tag_subheader")
			if [[ -z "$sub_tag_index" ]]; then
				echo "Not found subtag ${sub_tag} of tag ${TAG} in $tag_subheader" >&2
				continue
			fi
			for s_idx in $sub_tag_index; do
				col_indices+=( $(( first_index + s_idx - 1 )) )
				col_headers+=( "${SUB_TAGS[$sub_tag]}" )
			done
		done
	done

	if [[ ${#col_indices[@]} -eq 0 ]]; then
		return
	fi

	local cut_fields new_header
	cut_fields=$(IFS=','; echo "${col_indices[*]}")
	new_header=$(IFS=','; echo "${col_headers[*]}")

	# Extracción de todas las columnas de una sola vez y un único paste sobre DAT_FILE
	local tmp_cols="${DAT_FILE}.newcols.tmp"
	awk -F',' -v OFS=',' -v cols="$cut_fields" -v hdr="$new_header" '
		BEGIN {
			print hdr;
			n = split(cols, c, ",");
		}
		{
			for (i = 1; i <= n; i++) {
				printf "%s%s", $(c[i]), (i == n ? ORS : OFS);
			}
		}' <<< "$STAT_CONTENTS" > "$tmp_cols"

	paste -d "," "$DAT_FILE" "$tmp_cols" > "$TMP_DAT_FILE"
	mv "$TMP_DAT_FILE" "$DAT_FILE"
	rm -f "$tmp_cols"
}

function sum_files() {
	paste -d " " "$1" "$2" | awk '{printf("%.4f\n", ($1 + $2))}' > "$3"
}

function div_file() {
	awk -v div="$2" '{printf("%.4f\n", ($1 / div))}' "$1" > "$3"
}

function avg_file_rows() {
	awk '{s=0; for(i=1; i<=NF; i++) s+=$i; printf("%.4f\n", NF>0 ? s/NF : 0)}' "$1" > "$2"
}

function sum_dat_file() {
	local tag_indexes
	tag_indexes=$(get_index "$TAG" "$HEADER")

	local -a col_indices=()
	for first_index in $tag_indexes; do
		local last_index=$(( first_index + NVALUES - 1 ))
		local tag_subheader
		tag_subheader=$(cut -d "," -f "${first_index}-${last_index}" <<< "$SUBHEADER")

		for sub_tag in "${!SUB_TAGS[@]}"; do
			local sub_tag_index
			sub_tag_index=$(get_index "$sub_tag" "$tag_subheader")
			for s_idx in $sub_tag_index; do
				col_indices+=( $(( first_index + s_idx - 1 )) )
			done
		done
	done

	if [[ ${#col_indices[@]} -eq 0 ]]; then
		return
	fi

	local cut_fields
	cut_fields=$(IFS=','; echo "${col_indices[*]}")

	# Suma horizontal fila por fila en streaming sin crear archivos intermedios
	local tmp_sum="${DAT_FILE}.sumcol.tmp"
	awk -F',' -v cols="$cut_fields" -v sum_tag="$SUM_TAG" '
		BEGIN {
			n = split(cols, c, ",");
			print sum_tag;
		}
		{
			s = 0;
			for (i = 1; i <= n; i++) s += $(c[i]);
			printf "%.4f\n", s;
		}' <<< "$STAT_CONTENTS" > "$tmp_sum"

	paste -d "," "$DAT_FILE" "$tmp_sum" > "$TMP_DAT_FILE"
	mv "$TMP_DAT_FILE" "$DAT_FILE"
	rm -f "$tmp_sum"
}

function avg_dat_file() {
	local -a target_files=()
	local input_file dir
	for input_file in $INPUT_DAT_FILES; do
		[[ -f "$input_file" ]] || continue
		dir=$(basename "$(dirname "$input_file")")
		if [[ "$dir" != "node-0" ]]; then
			target_files+=("$input_file")
		fi
	done

	if [[ ${#target_files[@]} -eq 0 ]]; then
		return
	fi

	DAT_FILE="${FILE_PREFIX}.dat"
	AVG_DAT_FILE="${FILE_PREFIX}_avg.dat"
	SUM_DAT_FILE="${FILE_PREFIX}_sum.dat"

	awk -F',' -v OFS=',' \
	    -v dat_file="$DAT_FILE" \
	    -v avg_file="$AVG_DAT_FILE" \
	    -v sum_file="$SUM_DAT_FILE" \
	    -v epoch_hdr="$EPOCH_HEADER" '
	NR == FNR && FNR == 1 {
		ncols = NF;
		for (c = 1; c <= NF; c++) headers[c] = $c;
		next;
	}
	FNR == 1 {
		nfiles++;
		next;
	}
	{
		r = FNR - 1;
		if (r > max_r) max_r = r;
		for (c = 1; c <= NF; c++) {
			sum_cell[r, c] += $c;
			count_cell[r, c]++;
		}
	}
	END {
		# 1. Generar DAT_FILE (promedio dividiendo entre nodos activos en cada fila)
		for (c = 1; c <= ncols; c++) {
			printf "%s%s", headers[c], (c == ncols ? ORS : OFS) > dat_file;
		}
		for (r = 1; r <= max_r; r++) {
			for (c = 1; c <= ncols; c++) {
				cnt = count_cell[r, c];
				avg_val = sum_cell[r, c] / nfiles;
				avg_val = (cnt > 0) ? (sum_cell[r, c] / cnt) : 0;
				printf "%.4f%s", avg_val, (c == ncols ? ORS : OFS) > dat_file;
				if (headers[c] != epoch_hdr) {
					col_sum[c] += avg_val;
				}
			}
		}

		# 2. Generar AVG_DAT_FILE y SUM_DAT_FILE (cabeceras)
		first = 1;
		for (c = 1; c <= ncols; c++) {
			if (headers[c] == epoch_hdr) continue;
			printf "%s%s", (first ? "" : OFS), headers[c] > avg_file;
			printf "%s%s", (first ? "" : OFS), headers[c] > sum_file;
			first = 0;
		}
		printf ORS > avg_file;
		printf ORS > sum_file;

		# 3. Generar AVG_DAT_FILE y SUM_DAT_FILE (valores agregados de columna)
		first = 1;
		for (c = 1; c <= ncols; c++) {
			if (headers[c] == epoch_hdr) continue;
			c_avg = (max_r > 0) ? (col_sum[c] / max_r) : 0;
			printf "%s%.4f", (first ? "" : OFS), c_avg > avg_file;
			printf "%s%.4f", (first ? "" : OFS), col_sum[c] > sum_file;
			first = 0;
		}
		printf ORS > avg_file;
		printf ORS > sum_file;
	}' "${target_files[@]}"
}

function plot_dat_file_lines() {
	PLOT_FILE="${FILE_PREFIX}.eps"
	DAT_HEAD=$(head -n 1 "$DAT_FILE")
	local commas="${DAT_HEAD//[^,]/}"
	COLS=${#commas}
	MAX_EPOCH=$(tail -n 1 "$DAT_FILE" | cut -d "," -f 1)
	TICS_INTERVAL=$(op_int $MAX_EPOCH / 300 \* 60)
	if [[ -z "$TICS_INTERVAL" || "$TICS_INTERVAL" == "0" ]]; then
		TICS_INTERVAL=30
	fi
	echo $GNUPLOT_BIN -e "\"input_file='$DAT_FILE';output_file='$PLOT_FILE'; \
		tic_interval=$TICS_INTERVAL; max_x='$MAX_EPOCH'; \
		label_y='$YLABEL'; format_y='$YFORMAT'; \
		palette_file='$PALETTE_FILE'; \
		cols='$COLS'\"" "$STAT_PLOT_HOME/lines_graph.gplot" >> "$GRAPHS_SCRIPT"
}

function plot_dat_file_boxes() {
	PLOT_FILE="${FILE_PREFIX}.eps"
	DAT_HEAD=$(head -n 1 "$DAT_FILE")
	local commas="${DAT_HEAD//[^,]/}"
	COLS=${#commas}
	MAX_EPOCH=$(tail -n 1 "$DAT_FILE" | cut -d "," -f 1)
	TICS_INTERVAL=$(op_int $MAX_EPOCH / 300 \* 60)
	if [[ -z "$TICS_INTERVAL" || "$TICS_INTERVAL" == "0" ]]; then
		TICS_INTERVAL=30
	fi
	echo $GNUPLOT_BIN -e "\"input_file='$DAT_FILE';output_file='$PLOT_FILE'; \
		tic_interval=$TICS_INTERVAL; max_x='$MAX_EPOCH'; \
		label_y='$YLABEL'; format_y='$YFORMAT'; \
		palette_file='$PALETTE_FILE'; \
		cols='$COLS'\"" "$STAT_PLOT_HOME/boxes_graph.gplot" >> "$GRAPHS_SCRIPT"
}

function plot_dat_file_stacked() {
	STOCKED_PLOT_FILE="${FILE_PREFIX}_stacked.eps"
	DAT_HEAD=$(head -n 1 "$DAT_FILE")
	local commas="${DAT_HEAD//[^,]/}"
	COLS=${#commas}
	MAX_EPOCH=$(tail -n 1 "$DAT_FILE" | cut -d "," -f 1)
	TICS_INTERVAL=$(op_int $MAX_EPOCH / 300 \* 60)
	if [[ -z "$TICS_INTERVAL" || "$TICS_INTERVAL" == "0" ]]; then
		TICS_INTERVAL=30
	fi
	echo $GNUPLOT_BIN -e "\"input_file='$DAT_FILE';output_file='$STOCKED_PLOT_FILE'; \
		tic_interval=$TICS_INTERVAL; max_x='$MAX_EPOCH'; \
		label_y='$YLABEL'; format_y='$YFORMAT'; \
		palette_file='$PALETTE_FILE'; \
		cols='$COLS'; \"" "$STAT_PLOT_HOME/stacked_graph.gplot" >> "$GRAPHS_SCRIPT"
}
