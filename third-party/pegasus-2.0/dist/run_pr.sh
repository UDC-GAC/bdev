# Program : run_pr.sh
# Description : Run PageRank-plain, a PageRank calculation algorithm on hadoop.

which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi

if [ $# -ne 4 ]; then
	 echo 1>&2 Usage: $0 [#_of_nodes] [#_of_reducers] [HDFS edge_file_path] [makesym or nosym]
	 echo 1>&2 [#_of_nodes] : number of nodes in the graph
	 echo 1>&2 [#_of_reducers] : number of reducers to use in hadoop. 
	 echo 1>&2 [HDFS edge_file_path] : HDFS directory where edge file is located
	 echo 1>&2 [makesym or nosym] : makesym-duplicate reverse edges, nosym-use original edge file
	 echo 1>&2    ex: $0 16 5 pr_edge makesym
	 exit 127
fi

hadoop dfs -rmr pr_tempmv
hadoop dfs -rmr pr_output
hadoop dfs -rmr pr_minmax
hadoop dfs -rmr pr_distr

hadoop jar pegasus-2.0.jar pegasus.PagerankNaive $3 pr_tempmv pr_output $1 $2 1024 $4 new
