#!/bin/bash

RAPL_ENERGY_SUMMARY_FILE=$RAPL_PLOT_DIR/energy_summary.csv
RAPL_ED2P_SUMMARY_FILE=$RAPL_PLOT_DIR/ed2p_summary.csv

BENCHMARK_INPUT_DIRS=`find $SOLUTION_REPORT_DIR -wholename */${BENCHMARK}_*/rapl_records/avg`

for BENCHMARK_INPUT_DIR in $BENCHMARK_INPUT_DIRS
do
	cat $BENCHMARK_INPUT_DIR/energy_total | sed "s/^/${CLUSTER_SIZE},${SOLUTION},${BENCHMARK},/" >> $RAPL_ENERGY_SUMMARY_FILE
	cat $BENCHMARK_INPUT_DIR/ed2p | sed "s/^/${CLUSTER_SIZE},${SOLUTION},${BENCHMARK},/" >> $RAPL_ED2P_SUMMARY_FILE
done

CLUSTERS=`echo $CLUSTER_SIZES | wc -w`
STEP=0.9
COLS=`echo $SOLUTIONS | wc -w`
BOX_SIZE=`op "$STEP / $COLS"`
MINX=`op_int "-1 "`
MAXX=`op_int "$CLUSTERS "`
YLABEL_ENERGY="Energy (J)"
YLABEL_ED2P="ED2P"

DAT_HEADER="cluster_size"

for SOLUTION in $SOLUTIONS
do
	DAT_HEADER="$DAT_HEADER ${SOLUTION} ${SOLUTION}_MIN ${SOLUTION}_MAX"
done

RAPL_OUTPUT_DIR=$RAPL_PLOT_DIR/${BENCHMARK}

if [[ ! -d $RAPL_OUTPUT_DIR ]]
then
	mkdir -p $RAPL_OUTPUT_DIR
fi

ENERGY_OUTPUT_FILE=${RAPL_OUTPUT_DIR}/energy.dat
ENERGY_PLOT_FILE=${RAPL_OUTPUT_DIR}/energy.eps
TITLE_TAG="$BENCHMARK_TAG energy (J)"
echo "$DAT_HEADER" > $ENERGY_OUTPUT_FILE
ENERGY_SUMMARY=`cat $RAPL_ENERGY_SUMMARY_FILE | grep ",${BENCHMARK},"`

for CLUSTER_SIZE in $CLUSTER_SIZES
do
	OUTPUTLINE=""

	for SOLUTION in $SOLUTIONS
	do
		LINE=`echo "$ENERGY_SUMMARY" | egrep "^${CLUSTER_SIZE},${SOLUTION},"`
		ENERGIES=`echo "$LINE" | cut -f 4 -d ","`

		median $ENERGIES
		maxmin $ENERGIES

		if [[ $COUNT -eq 0 ]]
		then
			MEDIAN="?"
			MAX="?"
			MIN="?"
		fi

		OUTPUTLINE="$OUTPUTLINE $MEDIAN $MIN $MAX"
	done
	if [[ -n `echo "$OUTPUTLINE" | tr -d "?" | tr -d " "` ]]
	then
		OUTPUTLINE="$CLUSTER_SIZE$OUTPUTLINE"
		echo "$OUTPUTLINE" >> $ENERGY_OUTPUT_FILE
	fi
done

gnuplot -e "input_file='$ENERGY_OUTPUT_FILE';output_file='$ENERGY_PLOT_FILE'; \
	palette_file='$PLOT_HOME/palette.plt'; \
	box_size='$BOX_SIZE'; \
	cols='$COLS'; label_y='$YLABEL_ENERGY'; label_xtics='$CLUSTER_SIZES'; \
	title_tag='$TITLE_TAG'; \
	minx='$MINX';maxx='$MAXX'" $RAPL_PLOT_HOME/graph_energy.gplot 


ED2P_OUTPUT_FILE=${RAPL_OUTPUT_DIR}/ed2p.dat
ED2P_PLOT_FILE=${RAPL_OUTPUT_DIR}/ed2p.eps
TITLE_TAG="$BENCHMARK_TAG ED2P"
echo "$DAT_HEADER" > $ED2P_OUTPUT_FILE
ED2P_SUMMARY=`cat $RAPL_ED2P_SUMMARY_FILE | grep ",${BENCHMARK},"`

for CLUSTER_SIZE in $CLUSTER_SIZES
do
	OUTPUTLINE=""

	for SOLUTION in $SOLUTIONS
	do
		LINE=`echo "$ED2P_SUMMARY" | egrep "^${CLUSTER_SIZE},${SOLUTION},"`
		ENERGIES=`echo "$LINE" | cut -f 4 -d ","`

		median $ENERGIES
		maxmin $ENERGIES

		if [[ $COUNT -eq 0 ]]
		then
			MEDIAN="?"
			MAX="?"
			MIN="?"
		fi

		OUTPUTLINE="$OUTPUTLINE $MEDIAN $MIN $MAX"
	done
	if [[ -n `echo "$OUTPUTLINE" | tr -d "?" | tr -d " "` ]]
	then
		OUTPUTLINE="$CLUSTER_SIZE$OUTPUTLINE"
		echo "$OUTPUTLINE" >> $ED2P_OUTPUT_FILE
	fi
done

gnuplot -e "input_file='$ED2P_OUTPUT_FILE';output_file='$ED2P_PLOT_FILE'; \
	palette_file='$PLOT_HOME/palette.plt'; \
	box_size='$BOX_SIZE'; \
	cols='$COLS'; label_y='$YLABEL_ED2P'; label_xtics='$CLUSTER_SIZES'; \
	title_tag='$TITLE_TAG'; \
	minx='$MINX';maxx='$MAXX'" $RAPL_PLOT_HOME/graph_ed2p.gplot 
