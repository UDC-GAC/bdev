#!/bin/sh

## Configuration of the workloads

export NUM_EXECUTIONS=1	# Number of times each benchmark is executed
export EXAMPLES_DATA_FORMAT="Sequence"	# Format used for WordCount, Sort and Grep. Values = [ Text | KeyValueText | Sequence ]
export BENCHMARK_WAIT_SECONDS=10	# Waiting time (seconds) before each execution of each workload
export BENCHMARK_SETUP="" # Command to run before each execution of each workload
export BENCHMARK_CLEANUP="" # Command to run after each execution of each workload
export FRAMEWORK_SETUP="" # Command to run before each execution of each framework
export FRAMEWORK_CLEANUP="" # Command to run after each execution of each framework

#Datasize for Wordcount
export WORDCOUNT_DATASIZE=$((1 * 1024 * 1024))	# Size of the input data set (Bytes)

#Sort
export SORT_DATASIZE=$((1 * 1024 * 1024))	# Size of the input data set (Bytes)

#Terasort
export TERASORT_DATASIZE=$((1 * 1024 * 1024))	# Size of the input data set (Bytes)

#Grep
export GREP_DATASIZE=$((1 * 1024 * 1024))	# Size of the input data set (Bytes)
export GREP_REGEX=".*toxoplasmosis.*"		# Regular expression

#TestDFSIO
export DFSIO_N_FILES=32		# Number of files to generate
export DFSIO_FILE_SIZE=10	# Size of each file (MBytes)

#PageRank
export PAGERANK_PAGES=50		# Number of pages in the data set (nodes of the graph)
export PAGERANK_MAX_ITERATIONS=1	# Maximum number of iterations

#Connected Components
export CC_PAGES=50		# Number of pages in the data set (nodes of the graph)
export CC_MAX_ITERATIONS=1	# Maximum number of iterations

#K-Means
export KMEANS_NUM_OF_CLUSTERS=5		# Number of clusters in the data set
export KMEANS_DIMENSIONS=3		# Number of dimensions of the data set
export KMEANS_NUM_OF_SAMPLES=30000	# Total number of samples 
export KMEANS_SAMPLES_PER_INPUTFILE=6000	# Number of samples per input file
export KMEANS_CONVERGENCE_DELTA=0.5	# Convergence delta 
export KMEANS_MAX_ITERATIONS=1		# Maximum number of iterations

#Bayes
export BAYES_PAGES=25000	# Number of pages in the data set
export BAYES_CLASSES=10		# Number of classes in the data set
export BAYES_NGRAMS=1		# Size of NGrams to create

#Aggregation
export AGGREGATION_PAGES=120		# Number of pages in the data set (nodes of the graph)
export AGGREGATION_USERVISITS=1000	# Number of user visits in the data set (edges of the graph)

#Join
export JOIN_PAGES=120		# Number of pages in the data set (nodes of the graph)
export JOIN_USERVISITS=1000	# Number of user visits in the data set (edges of the graph)

#Scan
export SCAN_PAGES=120		# Number of pages in the data set (nodes of the graph)
export SCAN_USERVISITS=1000	# Number of user visits in the data set (edges of the graph)

#Command
#export COMMAND=		# Command to run in batch mode (executable script or a directory containing only scripts)
#export PREPARE_COMMAND=	# Command to run to set up input datasets

#TIMEOUT
#export TESTDFSIO_TIMEOUT=0
#export WORDCOUNT_TIMEOUT=0
#export SORT_TIMEOUT=0
#export TERASORT_TIMEOUT=0
#export GREP_TIMEOUT=0
#export PAGERANK_TIMEOUT=0
#export CC_TIMEOUT=0
#export KMEANS_TIMEOUT=0
#export BAYES_TIMEOUT=0
#export AGGREGATION_TIMEOUT=0
#export JOIN_TIMEOUT=0
#export SCAN_TIMEOUT=0
#export COMMAND_TIMEOUT=0
