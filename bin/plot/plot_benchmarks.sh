#!/bin/bash

if [[ "$BENCHMARK" == "testdfsio" ]]; then
	bash "$PLOT_HOME/plot_benchmark_testdfsio.sh"
else
	bash "$PLOT_HOME/plot_benchmark_time.sh"
fi
