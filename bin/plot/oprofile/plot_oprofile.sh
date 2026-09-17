#!/bin/bash

. $OPROFILE_PLOT_HOME/functions.sh

PALETTE_FILE="$OPROFILE_PLOT_HOME/palette.plt"

unset OPROFILEINPUTFILES
for INPUT_FILE in $(find "${OPROFILELOGDIR}" -name "oprofile" | sort -u); do
	if [[ $(basename "$(dirname "$INPUT_FILE")") != "node-0" ]]; then
		OPROFILEINPUTFILES="$OPROFILEINPUTFILES $INPUT_FILE"
	fi
done

FIRST_FILE="${OPROFILEINPUTFILES%% *}"
NUM_LINES=$(wc -l < "$FIRST_FILE")
OUTPUT_NODE_SUM_FILE="${OPROFILELOGDIR}/sum.csv"

rm -f $OUTPUT_NODE_SUM_FILE

for ((i = 1; i <= NUM_LINES; i++)); do
	ROW_FIRST_FILE=$(get_row $i "$FIRST_FILE")
	[[ -z "$ROW_FIRST_FILE" ]] && continue
	
	EVENT="${ROW_FIRST_FILE%%,*}"
	unset VALUE
	unset PERCENT
	VALUE_SUM="0"
	PERCENT_SUM="0"

	for f in $OPROFILEINPUTFILES; do
		ROW=$(get_row $i "$f")
		IFS=',' read -r _ VALUE PERCENT <<< "$ROW"
		VALUE_SUM=$(op_int "$VALUE + $VALUE_SUM")
		PERCENT_SUM=$(op "$PERCENT + $PERCENT_SUM")
	done

	echo "$EVENT,$VALUE_SUM,$PERCENT_SUM"
done > "$OUTPUT_NODE_SUM_FILE"
