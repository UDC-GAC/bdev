#!/bin/bash

if [ -z "$1" ]; then
	echo "Error: output directory not defined (\$1)." >&2
	exit 1
fi

OUTPUT_DIR="$1"
DAT_LEGEND_FILE="${OUTPUT_DIR}/legend.dat"
PLOT_LEGEND_FILE="${OUTPUT_DIR}/legend.eps"

DAT_HEADER=""
DAT_LINE=""

for FRAMEWORK in $FRAMEWORKS; do
	DAT_HEADER="${DAT_HEADER:+${DAT_HEADER} }${FRAMEWORK}"
	DAT_LINE="${DAT_LINE:+${DAT_LINE} }1"
done

echo "$DAT_HEADER" > "$DAT_LEGEND_FILE"
echo "$DAT_LINE" >> "$DAT_LEGEND_FILE"

COLS=$(echo $FRAMEWORKS | wc -w)

GNUPLOT_ARGS="input_file='${DAT_LEGEND_FILE}'; legend_file='${PLOT_LEGEND_FILE}'; palette_file='${PLOT_HOME}/palette.plt'; cols='${COLS}'"

echo "${GNUPLOT_BIN} -e \"${GNUPLOT_ARGS}\" \"${PLOT_HOME}/legend.gplot\""
$GNUPLOT_BIN -e "${GNUPLOT_ARGS}" "${PLOT_HOME}/legend.gplot"
