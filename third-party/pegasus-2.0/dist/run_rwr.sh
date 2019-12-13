# Program : run_pr.sh
# Description : Run RWR-plain, a RWR calculation algorithm on hadoop.

which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi

if [ $# -ne 7 ]; then
	 echo 1>&2 Usage: $0 [HDFS edge_file_path] [query path] [#_of_nodes] [#_of_reducers] [makesym or nosym] [new or contNN] [c]
	 echo 1>&2 [HDFS edge_file_path] : HDFS directory where edge file is located
	 echo 1>&2 [query path] : HDFS directory containing query nodes
	 echo 1>&2 [#_of_nodes] : number of nodes in the graph
	 echo 1>&2 [#_of_reducers] : number of reducers to use in hadoop. 
	 echo 1>&2 [makesym or nosym] : makesym-duplicate reverse edges, nosym-use original edge file
	 echo 1>&2 [new or contNN] : starts from scratch, or continue from the iteration NN
	 echo 1>&2 [c] : mixing component. Default value is 0.85.
	 echo 1>&2    ex: $0 rwr_edge rwr_query 16 3 nosym new 0.85
	 exit 127
fi

hadoop jar pegasus-2.0.jar pegasus.RWRNaive $1 $2 $3 $4 1024 $5 $6 $7
