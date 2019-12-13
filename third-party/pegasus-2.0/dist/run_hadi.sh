# Program : run_hadi.sh
# Description : Run HADI, a diameter/radii estimation algorithm on hadoop.

which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi

if [ $# -ne 5 ]; then
	 echo 1>&2 Usage: $0 [#_of_nodes] [#_of_reducers] [HDFS edge_file_path] [makesym or nosym] [enc or noenc]
	 echo 1>&2 [#_of_nodes] : number of nodes in the graph
	 echo 1>&2 [#_of_reducers] : number of reducers to use in hadoop
	 echo 1>&2 [HDFS edge_file_path] : HDFS directory where edge file is located
	 echo 1>&2 [makesym or nosym] : makesym-duplicate reverse edges, nosym-use original edge file
         echo 1>&2 [enc or noenc] : use bit-shuffle encoding or not
	 echo 1>&2    ex: $0 6 3 hadi_edge makesym noenc
	 exit 127
fi

rm -rf hadi_output_temp*
hadoop dfs -rmr hadi_curbm
hadoop dfs -rmr hadi_tempbm
hadoop dfs -rmr hadi_nextbm
hadoop dfs -rmr hadi_output

radius_path=hadi_radius
radius_summary_path=hadi_radius_summary
hadoop dfs -rmr $radius_path
hadoop dfs -rmr $radius_summary_path

hadoop jar pegasus-2.0.jar pegasus.Hadi $3 hadi_curbm hadi_tempbm hadi_nextbm hadi_output $1 32 $2 $5 newbm $4 max

local_output_path=hadi_output$1_temp
rm -rf $local_output_path

echo "Radius Summary:"
echo "Rad r	Count(r)"
hadoop dfs -cat $radius_summary_path/*
