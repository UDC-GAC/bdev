#!/bin/sh

mkdir -p $RAPLTMPDIR

cp $RAPL_HOME/rapl_plot/rapl_plot $RAPLTMPDIR/rapl_plot

sudo setcap cap_sys_rawio=ep $RAPLTMPDIR/rapl_plot

$RAPLTMPDIR/rapl_plot $RAPLLOGFILE $RAPL_SECONDS_INTERVAL

