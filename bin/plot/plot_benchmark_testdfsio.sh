#!/bin/bash

TESTDFSIO_WRITE_CONTENTS=""
TESTDFSIO_READ_CONTENTS=""
YLABEL="Throughput (MB/s)"

while IFS= read -r FILE; do
	dir="${FILE%/*}"          # Removes /output -> .../cluster/framework/testdfsio_*
	dir="${dir%/*}"           # Removes /testdfsio_* -> .../cluster/framework
	FRAMEWORK="${dir##*/}"    # Extracts the framework
	dir="${dir%/*}"           # Removes /framework -> .../cluster
	CLUSTER_SIZE="${dir##*/}" # Extracts the cluster size

	# Clean extraction of throughput in a single pass (the number is the last field, $NF)
	WRITE_TP=$(awk '/TestDFSIO ----- : write/{f=1} f && /Throughput/{print $NF; exit}' "$FILE")
	if [[ -n "$WRITE_TP" ]]; then
		TESTDFSIO_WRITE_CONTENTS+="${CLUSTER_SIZE}"$'\t'"${FRAMEWORK}"$'\t'"${BENCHMARK}_write"$'\t'"${WRITE_TP}"$'\n'
	fi

	READ_TP=$(awk '/TestDFSIO ----- : read/{f=1} f && /Throughput/{print $NF; exit}' "$FILE")
	if [[ -n "$READ_TP" ]]; then
		TESTDFSIO_READ_CONTENTS+="${CLUSTER_SIZE}"$'\t'"${FRAMEWORK}"$'\t'"${BENCHMARK}_read"$'\t'"${READ_TP}"$'\n'
	fi
done < <(find "$REPORT_DIR" -type f -wholename "*/testdfsio_*/output")

if [[ -n "$TESTDFSIO_WRITE_CONTENTS" ]]; then
	BENCHMARK_TAG="TestDFSIO Write Throughput"
	REPORT_CONTENTS="$TESTDFSIO_WRITE_CONTENTS"
	DAT_FILE="$PLOT_DIR/${BENCHMARK}_write.dat"
	PLOT_FILE="$PLOT_DIR/${BENCHMARK}_write.eps"
	. "$PLOT_HOME/gen_plot.sh"
fi

if [[ -n "$TESTDFSIO_READ_CONTENTS" ]]; then
	BENCHMARK_TAG="TestDFSIO Read Throughput"
	REPORT_CONTENTS="$TESTDFSIO_READ_CONTENTS"
	DAT_FILE="$PLOT_DIR/${BENCHMARK}_read.dat"
	PLOT_FILE="$PLOT_DIR/${BENCHMARK}_read.eps"
	. "$PLOT_HOME/gen_plot.sh"
fi
