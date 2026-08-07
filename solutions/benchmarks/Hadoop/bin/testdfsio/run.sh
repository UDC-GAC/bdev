#!/bin/sh

TESTDFSIO="${HADOOP_EXECUTABLE} org.apache.hadoop.fs.TestDFSIO"
COMMAND="$TESTDFSIO -write -nrFiles $DFSIO_N_FILES -fileSize $DFSIO_FILE_SIZE ;
$TESTDFSIO -read -nrFiles $DFSIO_N_FILES -fileSize $DFSIO_FILE_SIZE"

run_benchmark "$COMMAND"

if [ $(cat $TMPLOGFILE | grep -i -E "job failed|FinalApplicationStatus=FAILED" | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
else
	READ_OUTPUT=`grep "TestDFSIO ----- : read" $TMPLOGFILE -A 8 `
	READ_THROUGHPUT_LINE=`echo "$READ_OUTPUT" | grep "Throughput"`
	READ_THROUGHPUT=${READ_THROUGHPUT_LINE##*Throughput mb/sec:}

	m_echo "Read throughput: $READ_THROUGHPUT"

	WRITE_OUTPUT=`grep "TestDFSIO ----- : write" $TMPLOGFILE -A 8 `
	WRITE_THROUGHPUT_LINE=`echo "$WRITE_OUTPUT" | grep "Throughput"`
	WRITE_THROUGHPUT=${WRITE_THROUGHPUT_LINE##*Throughput mb/sec:}

	m_echo "Write throughput: $WRITE_THROUGHPUT"
fi
