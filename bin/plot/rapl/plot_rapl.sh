#!/bin/bash

. $RAPL_PLOT_HOME/functions.sh
. $RAPL_PLOT_HOME/constants.sh


cd ${RAPLLOGDIR}

GRAPHS_SCRIPT=${RAPLLOGDIR}/gen_graphs.sh
echo "$SCRIPT_HEADER" > ${GRAPHS_SCRIPT}

RAPLNODEDIRS=`find -name "node-*"`

unset ENERGY_PACKAGE_FILES
unset ENERGY_DRAM_FILES
unset ENERGY_PP0_FILES
unset ENERGY_PP1_FILES

unset POWER_PACKAGE_FILES
unset POWER_DRAM_FILES
unset POWER_PP0_FILES
unset POWER_PP1_FILES


for RAPLNODEDIR in $RAPLNODEDIRS
do
	YLABEL="Energy cnt"
	YFORMAT=""
	FILE_PREFIX=${RAPLNODEDIR}/rapl_energy_cnt_package
	plot_dat_file_lines
	FILE_PREFIX=${RAPLNODEDIR}/rapl_energy_cnt_dram
	plot_dat_file_lines
	FILE_PREFIX=${RAPLNODEDIR}/rapl_energy_cnt_pp0
	plot_dat_file_lines
	FILE_PREFIX=${RAPLNODEDIR}/rapl_energy_cnt_pp1
	plot_dat_file_lines
	FILE_PREFIX=${RAPLNODEDIR}/rapl_energy_cnt
	plot_dat_file_lines

	YLABEL="Energy (J)"
	YFORMAT=""
	FILE_PREFIX=${RAPLNODEDIR}/rapl_energy_joules_package
	plot_dat_file_lines
	ENERGY_PACKAGE_FILES="$ENERGY_PACKAGE_FILES $DAT_FILES"
	FILE_PREFIX=${RAPLNODEDIR}/rapl_energy_joules_dram
	plot_dat_file_lines
	ENERGY_DRAM_FILES="$ENERGY_DRAM_FILES $DAT_FILES"
	FILE_PREFIX=${RAPLNODEDIR}/rapl_energy_joules_pp0
	plot_dat_file_lines
	ENERGY_PP0_FILES="$ENERGY_PP0_FILES $DAT_FILES"
	FILE_PREFIX=${RAPLNODEDIR}/rapl_energy_joules_pp1
	plot_dat_file_lines
	ENERGY_PP1_FILES="$ENERGY_PP1_FILES $DAT_FILES"
	FILE_PREFIX=${RAPLNODEDIR}/rapl_energy_joules
	plot_dat_file_lines

	YLABEL="Power (W)"
	YFORMAT=""
	FILE_PREFIX=${RAPLNODEDIR}/rapl_power_package
	plot_dat_file_lines
	POWER_PACKAGE_FILES="$POWER_PACKAGE_FILES $DAT_FILES"
	FILE_PREFIX=${RAPLNODEDIR}/rapl_power_dram
	plot_dat_file_lines
	POWER_DRAM_FILES="$POWER_DRAM_FILES $DAT_FILES"
	FILE_PREFIX=${RAPLNODEDIR}/rapl_power_pp0
	plot_dat_file_lines
	POWER_PP0_FILES="$POWER_PP0_FILES $DAT_FILES"
	FILE_PREFIX=${RAPLNODEDIR}/rapl_power_pp1
	plot_dat_file_lines
	POWER_PP1_FILES="$POWER_PP1_FILES $DAT_FILES"
	FILE_PREFIX=${RAPLNODEDIR}/rapl_power
	plot_dat_file_lines
done


RAPL_AVG_DIR=./avg
rm -rf $RAPL_AVG_DIR
mkdir -p $RAPL_AVG_DIR


YLABEL="Energy (J)"
YFORMAT=""
INPUT_DAT_FILES=$ENERGY_PACKAGE_FILES
FILE_PREFIX=$RAPL_AVG_DIR/rapl_energy_joules_package
OUTPUT_TOT_SUM_FILE=${FILE_PREFIX}_total
TOTAL_PACKAGE_ENERGY_FILE=$OUTPUT_TOT_SUM_FILE
sum_dat_file
plot_dat_file_lines
INPUT_DAT_FILES=$ENERGY_DRAM_FILES
FILE_PREFIX=$RAPL_AVG_DIR/rapl_energy_joules_dram
OUTPUT_TOT_SUM_FILE=${FILE_PREFIX}_total
TOTAL_DRAM_ENERGY_FILE=$OUTPUT_TOT_SUM_FILE
sum_dat_file
plot_dat_file_lines
INPUT_DAT_FILES=$ENERGY_PP0_FILES
FILE_PREFIX=$RAPL_AVG_DIR/rapl_energy_joules_pp0
OUTPUT_TOT_SUM_FILE=${FILE_PREFIX}_total
sum_dat_file
plot_dat_file_lines
INPUT_DAT_FILES=$ENERGY_PP1_FILES
FILE_PREFIX=$RAPL_AVG_DIR/rapl_energy_joules_pp1
OUTPUT_TOT_SUM_FILE=${FILE_PREFIX}_total
sum_dat_file
plot_dat_file_lines
FILE_PREFIX=$RAPL_AVG_DIR/rapl_energy_joules
plot_dat_file_lines

TOTAL_PACKAGE_ENERGY=`cat $TOTAL_PACKAGE_ENERGY_FILE`
if [[ -f "$TOTAL_DRAM_ENERGY_FILE" ]]
then
	TOTAL_DRAM_ENERGY=`cat $TOTAL_DRAM_ENERGY_FILE`
	TOTAL_ENERGY=`op $TOTAL_PACKAGE_ENERGY + $TOTAL_DRAM_ENERGY`
else
	TOTAL_ENERGY=$TOTAL_PACKAGE_ENERGY
fi
ED2P=`op $ELAPSED_TIME ^ 2 \* $TOTAL_ENERGY`

echo $TOTAL_ENERGY > $RAPL_AVG_DIR/energy_total
echo $ED2P > $RAPL_AVG_DIR/ed2p

YLABEL="Power (W)"
YFORMAT=""
INPUT_DAT_FILES=$POWER_PACKAGE_FILES
FILE_PREFIX=${RAPL_AVG_DIR}/rapl_power_package
avg_dat_file
plot_dat_file_lines
INPUT_DAT_FILES=$POWER_DRAM_FILES
FILE_PREFIX=${RAPL_AVG_DIR}/rapl_power_dram
avg_dat_file
plot_dat_file_lines
INPUT_DAT_FILES=$POWER_PP0_FILES
FILE_PREFIX=${RAPL_AVG_DIR}/rapl_power_pp0
avg_dat_file
plot_dat_file_lines
INPUT_DAT_FILES=$POWER_PP1_FILES
FILE_PREFIX=${RAPL_AVG_DIR}/rapl_power_pp1
avg_dat_file
plot_dat_file_lines
FILE_PREFIX=${RAPL_AVG_DIR}/rapl_power
plot_dat_file_lines


chmod +x ${GRAPHS_SCRIPT}

if [[ ! -f ${REPORT_GEN_GRAPHS_FILE} ]]
then
	echo "$SCRIPT_HEADER" > ${REPORT_GEN_GRAPHS_FILE}
	chmod +x ${REPORT_GEN_GRAPHS_FILE}
fi

echo ".${GRAPHS_SCRIPT#${REPORT_DIR}}" >> ${REPORT_GEN_GRAPHS_FILE}

if [[ $RAPL_GEN_GRAPHS == "true" ]]
then
	${GRAPHS_SCRIPT}
fi
