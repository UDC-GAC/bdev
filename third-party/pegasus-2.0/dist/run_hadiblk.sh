# Program : run_hadiblk.sh
# Description : Run HADI-BLOCK, a block version of HADI

which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi


if [ $# -ne 6 ]; then
	 echo 1>&2 Usage: $0 [#_of_nodes] [#_of_reducers] [HDFS edge_file_path] [makesym or nosym] [block_width] [enc or noenc]
	 echo 1>&2 [#_of_nodes] : number of nodes in the graph
	 echo 1>&2 [#_of_reducers] : number of reducers to use in hadoop
	 echo 1>&2 [HDFS edge_file_path] : HDFS directory where edge file is located
	 echo 1>&2 [makesym or nosym] : makesym-make undirected graph, nosym-use directed graph
	 echo 1>&2 [block_width] : block width. usually set to 16.
	 echo 1>&2 [enc or noenc] : use bit shuffle encoding or not.
	 echo 1>&2    ex: $0 6 3 hadi_edge makesym 16 noenc
	 exit 127
fi

#### Step 1. Generate Init Vector
hadoop dfs -rmr hadi_initvector
hadoop jar pegasus-2.0.jar pegasus.HadiIVGen hadi_initvector $1 $2 32 $6

#### Step 2. Run mv_prep
hadoop dfs -rmr hadi_iv_block
hadoop dfs -rmr hadi_edge_block
./run_mvprep.sh hadi_initvector hadi_iv_block $1 $5 $2 s $4
hadoop dfs -rmr hadi_initvector

./run_mvprep.sh $3 hadi_edge_block $1 $5 $2 null $4

#### Step 3. Run pegasus.HadiBlock
hadoop dfs -rmr hadi_tempbm_block
hadoop dfs -rmr hadi_nextbm_block
hadoop dfs -rmr hadi_output_block
radius_path=hadi_radius_block
radius_summary_path=hadi_radius_block_summary
hadoop dfs -rmr $radius_path
hadoop dfs -rmr $radius_summary_path

hadoop jar pegasus-2.0.jar pegasus.HadiBlock hadi_edge_block hadi_iv_block hadi_tempbm_block hadi_nextbm_block hadi_output_block $1 32 $2 $6 newbm $5 max

local_output_path=hadi_output_block$1_tempblk
rm -rf $local_output_path

echo "Radius Summary:"
echo "Rad r	Count(r)"
hadoop dfs -cat $radius_summary_path/*
