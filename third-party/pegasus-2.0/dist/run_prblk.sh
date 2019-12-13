# Program : run_prblk.sh
# Description : Run PageRank-BLOCK, a block version of PageRank calculation on hadoop.

which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi

if [ $# -ne 5 ]; then
	 echo 1>&2 Usage: $0 [#_of_nodes] [#_of_reducers] [HDFS edge path] [makesym or nosym] [block width]
	 echo 1>&2 [#_of_nodes] : number of nodes in the graph
	 echo 1>&2 [#_of_reducers] : number of reducers to use in hadoop
	 echo 1>&2 [HDFS edge_file_path] : HDFS directory where edge file is located
	 echo 1>&2 [makesym or nosym] : makesym for directed graph, nosym for undirected graph
	 echo 1>&2 [block_width] : block width. usually set to 16.
	 echo 1>&2   Ex: $0 16 3 pr_edge makesym 2
	 exit 127
fi

#### Step 1. Generate Init Vector
hadoop dfs -rmr pr_input
hadoop dfs -rmr pr_initvector
hadoop jar pegasus-2.0.jar pegasus.PagerankInitVector pr_initvector $1 $2
hadoop dfs -rmr pr_input

#### Step 2. Run mv_prep
hadoop dfs -rmr pr_iv_block
./run_mvprep.sh pr_initvector pr_iv_block $1 $5 $2 s $4
hadoop dfs -rmr pr_initvector

./run_prprep.sh $3 pr_edge_colnorm $2 $4
hadoop dfs -rmr pr_edge_block
./run_mvprep.sh pr_edge_colnorm pr_edge_block $1 $5 $2 null nosym
hadoop dfs -rmr pr_edge_colnorm

#### Step 3. Run pegasus.PagerankBlock
echo "Now running pegasus.PagerankBlock..."

hadoop jar pegasus-2.0.jar pegasus.PagerankBlock pr_edge_block pr_iv_block pr_tempmv_block pr_output_block $1 $2 1024 $5
