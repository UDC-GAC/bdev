#!/bin/bash

FILES=`find $REPORT_DIR -wholename */testdfsio_*/output`

REPORT_CONTENTS=""

for FILE in $FILES
do
	SOLUTION=$(basename $( dirname $( dirname $FILE)))
	CLUSTER_SIZE=$(basename $(dirname $( dirname $(dirname $FILE))))
	
	CONTENT=`cat $FILE | grep "TestDFSIO ----- : write" -A 8` 
	if [[ -n "$CONTENT" ]]
	then
		LINE=`echo "$CONTENT" | grep Throughput`
		THROUGHPUT=`echo "$LINE" | tr -s " " | cut -f 7 -d " "`
		TESTDFSIO_WRITE_CONTENTS=`echo "$TESTDFSIO_WRITE_CONTENTS""$CLUSTER_SIZE \t $SOLUTION \t ${BENCHMARK}_write \t "$THROUGHPUT "\n"`
	fi

	CONTENT=`cat $FILE | grep "TestDFSIO ----- : read" -A 8` 
	if [[ -n "$CONTENT" ]]
	then
		LINE=`echo "$CONTENT" | grep Throughput`
		THROUGHPUT=`echo "$LINE" | tr -s " " | cut -f 7 -d " "`
		TESTDFSIO_READ_CONTENTS=`echo "$TESTDFSIO_READ_CONTENTS""$CLUSTER_SIZE \t $SOLUTION \t ${BENCHMARK}_read \t "$THROUGHPUT "\n"`
	fi

done

YLABEL="Throughput (MB/s)"

BENCHMARK_TAG="TestDFSIO Write Throughput"
REPORT_CONTENTS=`echo -e "$TESTDFSIO_WRITE_CONTENTS"`
DAT_FILE=$PLOT_DIR/${BENCHMARK}_write.dat
PLOT_FILE=$PLOT_DIR/${BENCHMARK}_write.eps
. $PLOT_HOME/gen_plot.sh

BENCHMARK_TAG="TestDFSIO Read Throughput"
REPORT_CONTENTS=`echo -e "$TESTDFSIO_READ_CONTENTS"`
DAT_FILE=$PLOT_DIR/${BENCHMARK}_read.dat
PLOT_FILE=$PLOT_DIR/${BENCHMARK}_read.eps
. $PLOT_HOME/gen_plot.sh