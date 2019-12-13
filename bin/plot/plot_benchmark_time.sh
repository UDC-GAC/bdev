#!/bin/bash

YLABEL="Time (s)"
BENCHMARK_TAG="${BENCHMARK^} execution times"
REPORT_CONTENTS=`cat $REPORT_FILE | grep " ${BENCHMARK} " | tr -s "\t"`
DAT_FILE=$PLOT_DIR/${BENCHMARK}.dat
PLOT_FILE=$PLOT_DIR/${BENCHMARK}.eps


. $PLOT_HOME/gen_plot.sh