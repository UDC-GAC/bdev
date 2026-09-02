#!/bin/bash

TESTDFSIO="${HADOOP_EXECUTABLE} org.apache.hadoop.fs.TestDFSIO"
COMMAND="$TESTDFSIO -write -nrFiles $DFSIO_N_FILES -fileSize $DFSIO_FILE_SIZE ;
$TESTDFSIO -read -nrFiles $DFSIO_N_FILES -fileSize $DFSIO_FILE_SIZE"

run_benchmark "$COMMAND"

if [[ "$ELAPSED_TIME" != "TIMEOUT" && "$ELAPSED_TIME" != "FAILED" ]]; then
	WRITE_THROUGHPUT=$(grep -A 8 "TestDFSIO ----- : write" "$TMPLOGFILE" | awk '/Throughput mb\/sec:/ {print $NF}')
	READ_THROUGHPUT=$(grep -A 8 "TestDFSIO ----- : read" "$TMPLOGFILE" | awk '/Throughput mb\/sec:/ {print $NF}')
	m_echo "Write/Read throughput (MB/s): $WRITE_THROUGHPUT/$READ_THROUGHPUT"
fi
