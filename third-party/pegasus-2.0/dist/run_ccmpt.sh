# Program : run_ccmpt.sh
# Description : Run HCC, a connected component algorithm on hadoop.

which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi


if [ $# -ne 3 ]; then
	 echo 1>&2 Usage: $0 [#_of_nodes] [#_of_reducers] [HDFS edge_file_path]
	 echo 1>&2 [#_of_nodes] : number of nodes in the graph
	 echo 1>&2 [#_of_reducers] : number of reducers to use in hadoop
	 echo 1>&2 [HDFS edge_file_path] : HDFS directory where edge file is located
	 echo 1>&2    ex: $0 6 3 cc_edge
	 exit 127
fi

rm -rf concmpt_output_temp

hadoop dfs -rmr concmpt_curbm
hadoop dfs -rmr concmpt_tempbm
hadoop dfs -rmr concmpt_nextbm
hadoop dfs -rmr concmpt_output
hadoop dfs -rmr concmpt_summaryout

hadoop jar pegasus-2.0.jar pegasus.ConCmpt $3 concmpt_curbm concmpt_tempbm concmpt_nextbm concmpt_output $1 $2 new makesym

rm -rf concmpt_output_temp
