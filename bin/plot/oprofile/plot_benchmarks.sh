#!/bin/bash

[[ "$GNUPLOT_BIN" != "null" ]] && m_echo "Generating Oprofile plots"

OPROFILE_SUMMARY_FILE=$OPROFILE_PLOT_DIR/summary.csv

BENCHMARK_INPUT_FILES=$(find $FRAMEWORK_REPORT_DIR -wholename */${BENCHMARK}_*/sum.csv)

for BENCHMARK_INPUT_FILE in $BENCHMARK_INPUT_FILES; do
	sed "s/^/${CLUSTER_SIZE},${FRAMEWORK},${BENCHMARK},/" "$BENCHMARK_INPUT_FILE" >> "$OPROFILE_SUMMARY_FILE"
done

EVENTS=$(cut -f 4 -d "," "$OPROFILE_SUMMARY_FILE" | sort -u)
CLUSTERS=$(echo $CLUSTER_SIZES | wc -w)
STEP=0.9
COLS=$(echo $FRAMEWORKS | wc -w)
BOX_SIZE=$(op "$STEP / $COLS")
MINX=$(op_int "-1 ")
MAXX=$(op_int "$CLUSTERS ")
YLABEL="Counter value"
DAT_HEADER="cluster_size"

for FRAMEWORK in $FRAMEWORKS; do
	DAT_HEADER="$DAT_HEADER ${FRAMEWORK} ${FRAMEWORK}_MIN ${FRAMEWORK}_MAX"
done

for EVENT in $EVENTS; do
	EVENT_OUTPUT_DIR="$OPROFILE_PLOT_DIR/${BENCHMARK}"
	[[ -d "$EVENT_OUTPUT_DIR" ]] || mkdir -p "$EVENT_OUTPUT_DIR"

	EVENT_OUTPUT_FILE="$EVENT_OUTPUT_DIR/${EVENT}.dat"
	EVENT_PLOT_FILE="$EVENT_OUTPUT_DIR/${EVENT}.eps"
	TITLE_TAG="$BENCHMARK_TAG $EVENT"

	echo "$DAT_HEADER" > "$EVENT_OUTPUT_FILE"
	EVENT_SUMMARY=$(grep ",${BENCHMARK},${EVENT}," "$OPROFILE_SUMMARY_FILE")

	for CLUSTER_SIZE in $CLUSTER_SIZES; do
		OUTPUTLINE=""

		for FRAMEWORK in $FRAMEWORKS; do
			LINE=$(grep -E "^${CLUSTER_SIZE},${FRAMEWORK}," <<< "$EVENT_SUMMARY")
			EVENT_COUNTERS=$(cut -f 5 -d "," <<< "$LINE")
			median $EVENT_COUNTERS
			maxmin $EVENT_COUNTERS

			if [[ $COUNT -eq 0 ]]; then
				MEDIAN="?"
				MAX="?"
				MIN="?"
			fi

			OUTPUTLINE="$OUTPUTLINE $MEDIAN $MIN $MAX"
		done

		if [[ -n $(tr -d "? " <<< "$OUTPUTLINE") ]]; then
			echo "${CLUSTER_SIZE}${OUTPUTLINE}" >> "$EVENT_OUTPUT_FILE"
		fi
	done

	if [[ "$GNUPLOT_BIN" != "null" ]]; then
		$GNUPLOT_BIN -e "input_file='$EVENT_OUTPUT_FILE';output_file='$EVENT_PLOT_FILE'; \
			palette_file='$PLOT_HOME/palette.plt'; \
			box_size='$BOX_SIZE'; \
			cols='$COLS'; label_y='$YLABEL'; label_xtics='$CLUSTER_SIZES'; \
			title_tag='$TITLE_TAG'; \
			minx='$MINX';maxx='$MAXX'" $OPROFILE_PLOT_HOME/graph.gplot
	fi
done
