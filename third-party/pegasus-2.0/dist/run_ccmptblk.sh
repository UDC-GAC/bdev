# Program : run_ccmptblk.sh
# Description : Run HCC-BLOCK, a block version of HCC

which hadoop > /dev/null
status=$?
if test $status -ne 0 ; then
	echo ""
	echo "Hadoop is not installed in the system."
	echo "Please install Hadoop and make sure the hadoop binary is accessible."
	exit 127
fi


if [ $# -ne 4 ]; then
	 echo 1>&2 Usage: $0 [#_of_nodes] [#_of_reducers] [HDFS edge_file_path] [block_width]
	 echo 1>&2 [#_of_nodes] : number of nodes in the graph
	 echo 1>&2 [#_of_reducers] : number of reducers to use in hadoop
	 echo 1>&2 [HDFS edge_file_path] : HDFS directory where edge file is located
	 echo 1>&2 [block_width] : block width. usually set to 16.
	 echo 1>&2    ex: $0 6 3 cc_edge 16
	 exit 127
fi

#### Step 1. Generate Init Vector
hadoop dfs -rmr cc_initvector
hadoop jar pegasus-2.0.jar pegasus.ConCmptIVGen cc_initvector $1 $2

#### Step 2. Run mv_prep
hadoop dfs -rmr cc_iv_block
hadoop dfs -rmr cc_edge_block
./run_mvprep.sh cc_initvector cc_iv_block $1 $4 $2 msc makesym
hadoop dfs -rmr cc_initvector

./run_mvprep.sh cc_edge cc_edge_block $1 $4 $2 null makesym

#### Step 3. Run pegasus.ConCmptBlock
rm -rf concmpt_output_temp
hadoop dfs -rmr concmpt_curbm
hadoop dfs -rmr concmpt_tempbm
hadoop dfs -rmr concmpt_nextbm
hadoop dfs -rmr concmpt_output
hadoop dfs -rmr concmpt_summaryout
hadoop dfs -rmr concmpt_curbm_unfold

hadoop jar pegasus-2.0.jar pegasus.ConCmptBlock cc_edge_block cc_iv_block concmpt_tempbm concmpt_nextbm concmpt_output $1 $2 fast $4

rm -rf concmpt_output_temp

