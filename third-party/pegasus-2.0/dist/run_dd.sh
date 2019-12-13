# Program : run_dd.sh
# Description : Run DegDist, a degree distribution computation on hadoop.

if [ $# -ne 3 ]; then
	 echo 1>&2 Usage: $0 [in or out or inout] [#_of_reducer] [HDFS edge_file_path]
	 echo 1>&2 [in or out or inout] : type of degree\(in, out, inout\) to compute
	 echo 1>&2 [#_of_reducers] : number of reducers to use in hadoop
	 echo 1>&2 [HDFS edge_file_path] : HDFS directory where edge file is located
	 echo 1>&2    ex: $0 in 16 dd_edge
	 exit 127
fi

hadoop dfs -rmr dd_node_deg
hadoop dfs -rmr dd_deg_count

hadoop jar pegasus-2.0.jar pegasus.DegDist $3 dd_node_deg dd_deg_count $1 $2
