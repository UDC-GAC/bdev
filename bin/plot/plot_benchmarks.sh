#!/bin/bash

[[ "$GNUPLOT_BIN" != "null" ]] && m_echo "Generating performance plots"

if [[ "$BENCHMARK" == "testdfsio" ]]; then
	bash "$PLOT_HOME/plot_benchmark_testdfsio.sh"
else
	bash "$PLOT_HOME/plot_benchmark_time.sh"
fi
