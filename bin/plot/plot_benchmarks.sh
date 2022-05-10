#!/bin/sh


if [[ "x$BENCHMARK" == "xtestdfsio" ]]
then
	bash $PLOT_HOME/plot_benchmark_testdfsio.sh
else
	bash $PLOT_HOME/plot_benchmark_time.sh
fi