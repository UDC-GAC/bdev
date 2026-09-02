#!/bin/bash

TESTDFSIO="${HADOOP_EXECUTABLE} org.apache.hadoop.fs.TestDFSIO"
COMMAND="$TESTDFSIO -write -nrFiles $DFSIO_N_FILES -fileSize $DFSIO_FILE_SIZE ;
$TESTDFSIO -read -nrFiles $DFSIO_N_FILES -fileSize $DFSIO_FILE_SIZE"

run_benchmark "$COMMAND"

if [[ "$ELAPSED_TIME" != "TIMEOUT" && "$ELAPSED_TIME" != "FAILED" ]]; then
	READ_OUTPUT=$(grep "TestDFSIO ----- : read" $TMPLOGFILE -A 8)
	READ_THROUGHPUT_LINE=`echo "$READ_OUTPUT" | grep "Throughput"`
	READ_THROUGHPUT=${READ_THROUGHPUT_LINE##*Throughput mb/sec:}
	WRITE_OUTPUT=$(grep "TestDFSIO ----- : write" $TMPLOGFILE -A 8)
	WRITE_THROUGHPUT_LINE=`echo "$WRITE_OUTPUT" | grep "Throughput"`
	WRITE_THROUGHPUT=${WRITE_THROUGHPUT_LINE##*Throughput mb/sec:}
	m_echo "Read/Write throughput (MB/s): $READ_THROUGHPUT/$WRITE_THROUGHPUT"
fi
