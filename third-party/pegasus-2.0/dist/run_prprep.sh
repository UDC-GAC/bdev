# Program : run_prprep.sh
# Description : Run PagerankPrep which converts the input edge file to the column-normalized adjacency matrix.

which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi

if [ $# -ne 4 ]; then
	 echo 1>&2 Usage: $0 [input HDFS path] [output HDFS path] [#_of_reducers] [makesym or nosym]
	 echo 1>&2 [input HDFS path] : HDFS directory where edge file is located
	 echo 1>&2 [output HDFS path] : HDFS directory where the result is to be saved
	 echo 1>&2 [#_of_reducers] : number of reducers to use in hadoop
	 echo 1>&2 [makesym or nosym] : makesym-duplicate reverse edges, nosym-use 
	 exit 127
fi

hadoop dfs -rmr $2

hadoop jar pegasus-2.0.jar pegasus.PagerankPrep $1 $2 $3 $4
