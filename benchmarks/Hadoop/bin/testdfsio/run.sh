#!/bin/bash

TESTDFSIO="${HADOOP_EXECUTABLE} org.apache.hadoop.fs.TestDFSIO"
WRITE_TEST="$TESTDFSIO -write -nrFiles $DFSIO_N_FILES -fileSize $DFSIO_FILE_SIZE"
READ_TEST="$TESTDFSIO -read -nrFiles $DFSIO_N_FILES -fileSize $DFSIO_FILE_SIZE"
WRITE_THROUGHPUT=""
READ_THROUGHPUT=""

run_benchmark "$WRITE_TEST"

if [[ "$ELAPSED_TIME" != "TIMEOUT" && "$ELAPSED_TIME" != "FAILED" ]]; then
	WRITE_THROUGHPUT=$(grep -A 8 "TestDFSIO ----- : write" "$TMPLOGFILE" | awk '/Throughput mb\/sec:/ {print $NF}')
fi

run_benchmark "$READ_TEST"

if [[ "$ELAPSED_TIME" != "TIMEOUT" && "$ELAPSED_TIME" != "FAILED" ]]; then
	READ_THROUGHPUT=$(grep -A 8 "TestDFSIO ----- : read" "$TMPLOGFILE" | awk '/Throughput mb\/sec:/ {print $NF}')

fi

if [[ -n "$WRITE_THROUGHPUT" && -n "$READ_THROUGHPUT" ]]; then
	m_echo "Write/Read throughput (MB/s): $WRITE_THROUGHPUT/$READ_THROUGHPUT"
fi
