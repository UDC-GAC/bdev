# Program : run_rwrblk.sh
# Description : Run RWR-BLOCK, a block version of RWR calculation on hadoop.

which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi

if [ $# -ne 7 ]; then
	 echo 1>&2 Usage: $0 [HDFS edge path] [query path] [#_of_nodes] [#_of_reducers] [makesym or nosym] [block width] [c]
	 echo 1>&2 [HDFS edge_file_path] : HDFS directory where edge file is located
	 echo 1>&2 [query path] : HDFS directory containing query nodes
	 echo 1>&2 [#_of_nodes] : number of nodes in the graph
	 echo 1>&2 [#_of_reducers] : number of reducers to use in hadoop
	 echo 1>&2 [makesym or nosym] : makesym for directed graph, nosym for undirected graph
	 echo 1>&2 [block_width] : block width. usually set to 16.
	 echo 1>&2 [c] : mixing component. Default value is 0.85.
	 echo 1>&2   ex: $0 rwr_edge rwr_query 16 3 nosym 8 0.85
	 exit 127
fi

#### Step 1. Generate Init Vector
hadoop dfs -rmr pr_input
hadoop dfs -rmr rwr_initvector
hadoop jar pegasus-2.0.jar pegasus.PagerankInitVector rwr_initvector $3 $4
hadoop dfs -rmr pr_input

#### Step 2. Run mv_prep
hadoop dfs -rmr rwr_iv_block
./run_mvprep.sh rwr_initvector rwr_iv_block $3 $6 $4 s $5
hadoop dfs -rmr rwr_initvector

./run_prprep.sh $1 rwr_edge_colnorm $4 $5
hadoop dfs -rmr rwr_edge_block
./run_mvprep.sh rwr_edge_colnorm rwr_edge_block $3 $6 $4 null nosym
hadoop dfs -rmr rwr_edge_colnorm

#### Step 3. Run RWR
echo "Now running RWR..."

hadoop jar pegasus-2.0.jar pegasus.RWRBlock rwr_edge_block rwr_iv_block $2 $3 $4 1024 $6 $7
