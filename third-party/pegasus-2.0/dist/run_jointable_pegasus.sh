# Program : run_jointable.sh
# Description : join tables. similar to the `join' command in UNIX.

which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi

if [ $# -lt 5 ]; then
	 echo 1>&2 Usage: $0 [#_of_reducers] [OuterJoin or SemiJoin] [HDFS output path] [HDFS input path 1] [input path 2...]
	 echo 1>&2 [#_of_reducers] : number of reducers to use in hadoop
	 exit 127
fi

hadoop jar pegasus-2.0.jar pegasus.JoinTablePegasus $*
