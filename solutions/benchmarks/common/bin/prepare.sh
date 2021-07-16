#!/bin/sh

if [[ $GEN_WORDCOUNT == "true" ]]
then
	m_echo "Generating Wordcount data: ${WORDCOUNT_DATASIZE} bytes"
	OPTIONS="-t randomtext \
		-n ${INPUT_WORDCOUNT} \
		-m ${MAPPERS_NUMBER} \
		-p ${WORDCOUNT_DATASIZE} \
		-outFormat ${EXAMPLES_OUTPUT_FORMAT}"

	${HADOOP_EXECUTABLE} jar ${DATAGEN_JAR} ${OPTIONS}
fi

if [[ $GEN_SORT == "true" ]]
then
	if [[ $GEN_WORDCOUNT == "true" && $SORT_DATASIZE == $WORDCOUNT_DATASIZE ]]
	then
		m_echo "Reusing $INPUT_WORDCOUNT as input for Sort"
		export INPUT_SORT=$INPUT_WORDCOUNT
	else
		m_echo "Generating Sort data: ${SORT_DATASIZE} bytes"
		OPTIONS="-t randomtext \
			-n ${INPUT_SORT} \
			-m ${MAPPERS_NUMBER} \
			-p ${SORT_DATASIZE} \
			-outFormat ${EXAMPLES_OUTPUT_FORMAT}"

		${HADOOP_EXECUTABLE} jar ${DATAGEN_JAR} ${OPTIONS}
	fi
fi

if [[ $GEN_GREP == "true" ]]
then
	if [[ $GEN_WORDCOUNT == "true" && $GREP_DATASIZE == $WORDCOUNT_DATASIZE ]]
	then
		m_echo "Reusing $INPUT_WORDCOUNT as input for Grep"
		export INPUT_GREP=$INPUT_WORDCOUNT
	elif [[ $GEN_SORT == "true" && $GREP_DATASIZE == $SORT_DATASIZE  ]]
	then
		m_echo "Reusing $INPUT_SORT as input for Grep"
		export INPUT_GREP=$INPUT_SORT
	else			
		m_echo "Generating Grep data: ${GREP_DATASIZE} bytes"
		OPTIONS="-t randomtext \
			-n ${INPUT_GREP} \
			-m ${MAPPERS_NUMBER} \
			-p ${GREP_DATASIZE} \
			-outFormat ${EXAMPLES_OUTPUT_FORMAT}"

		${HADOOP_EXECUTABLE} jar ${DATAGEN_JAR} ${OPTIONS}
	fi
fi
	
if [[ $GEN_TERASORT == "true" ]]
then
	m_echo "Generating Terasort data: ${TERASORT_DATASIZE} bytes"
	OPTIONS="-t teragen \
		-n ${INPUT_TERASORT} \
		-m ${MAPPERS_NUMBER} \
		-p ${TERASORT_ROWS_NUMBER}"

	${HADOOP_EXECUTABLE} jar ${DATAGEN_JAR} ${OPTIONS}
fi

if [[ $GEN_PAGERANK == "true" ]]
then
	m_echo "Generating PageRank data: ${PAGERANK_PAGES} pages"
	OPTIONS="-t pagerank \
		-n ${INPUT_PAGERANK} \
		-m ${MAPPERS_NUMBER} \
		-r ${REDUCERS_NUMBER} \
		-p ${PAGERANK_PAGES} \
		-pbalance -pbalance \
		-o text"

	${HADOOP_EXECUTABLE} jar ${DATAGEN_JAR} ${OPTIONS}
fi

if [[ $GEN_CC == "true" ]]
then
	if [[ $GEN_PAGERANK == "true" && $CC_PAGES == $PAGERANK_PAGES  ]]
	then
		m_echo "Reusing $INPUT_PAGERANK as input for Connected Components"
		export INPUT_CC=$INPUT_PAGERANK
	else
		m_echo "Generating Connected Components data: ${CC_PAGES} pages"
		OPTIONS="-t pagerank \
			-n ${INPUT_CC} \
			-m ${MAPPERS_NUMBER} \
			-r ${REDUCERS_NUMBER} \
			-p ${CC_PAGES} \
			-pbalance -pbalance \
			-o text"

		${HADOOP_EXECUTABLE} jar ${DATAGEN_JAR} ${OPTIONS}
    fi
fi

if [[ $GEN_KMEANS == "true" ]]
then
	m_echo "Generating KMeans data: ${KMEANS_NUM_OF_CLUSTERS} clusters, ${KMEANS_DIMENSIONS} dimensions, ${KMEANS_NUM_OF_SAMPLES} samples"
	OPTIONS="-t kmeans \
		-compress false \
		-sampleDir ${INPUT_KMEANS}/samples \
		-clusterDir ${INPUT_KMEANS}/cluster \
		-numClusters ${KMEANS_NUM_OF_CLUSTERS} \
		-numSamples ${KMEANS_NUM_OF_SAMPLES} \
		-samplesPerFile ${KMEANS_SAMPLES_PER_INPUTFILE} \
		-sampleDimension ${KMEANS_DIMENSIONS}"

	${HADOOP_EXECUTABLE} jar ${DATAGEN_JAR} ${OPTIONS}
fi

if [[ $GEN_BAYES == "true" ]]
then
	m_echo "Generating Bayes data: ${BAYES_PAGES} pages, ${BAYES_CLASSES} classes"
	OPTIONS="-t bayes \
		-n ${INPUT_BAYES} \
		-m ${MAPPERS_NUMBER} \
		-r ${REDUCERS_NUMBER} \
		-p ${BAYES_PAGES} \
		-g ${BAYES_CLASSES} \
		-o sequence"

	${HADOOP_EXECUTABLE} jar ${DATAGEN_JAR} ${OPTIONS}	
fi

if [[ $GEN_AGGREGATION == "true" ]]
then
	m_echo "Generating Aggregation data: ${AGGREGATION_PAGES} pages, ${AGGREGATION_USERVISITS} uservisits"
	OPTIONS="-t hive \
		-n ${INPUT_AGGREGATION} \
		-m ${MAPPERS_NUMBER} \
		-r ${REDUCERS_NUMBER} \
		-p ${AGGREGATION_PAGES} \
		-v ${AGGREGATION_USERVISITS} \
		-o sequence"

	${HADOOP_EXECUTABLE} jar ${DATAGEN_JAR} ${OPTIONS}
fi

if [[ $GEN_JOIN == "true" ]]
then
	if [[ $GEN_AGGREGATION == "true" && \
		$JOIN_PAGES == $AGGREGATION_PAGES && \
		$JOIN_USERVISITS == $AGGREGATION_USERVISITS ]]
	then
		m_echo "Reusing $INPUT_AGGREGATION as input for Join"
		export INPUT_JOIN=$INPUT_AGGREGATION
	else
		m_echo "Generating Join data: ${JOIN_PAGES} pages, ${JOIN_USERVISITS} uservisits"
		OPTIONS="-t hive \
			-n ${INPUT_JOIN} \
			-m ${MAPPERS_NUMBER} \
			-r ${REDUCERS_NUMBER} \
			-p ${JOIN_PAGES} \
			-v ${JOIN_USERVISITS} \
			-o sequence"
		
		${HADOOP_EXECUTABLE} jar ${DATAGEN_JAR} ${OPTIONS}
	fi
fi

if [[ $GEN_SCAN == "true" ]]
then
	if [[ $GEN_AGGREGATION == "true" && \
		$SCAN_PAGES == $AGGREGATION_PAGES && \
		$SCAN_USERVISITS == $AGGREGATION_USERVISITS ]]
	then
		m_echo "Reusing $INPUT_AGGREGATION as input for Scan"
		export INPUT_SCAN=$INPUT_AGGREGATION
	elif [[ $GEN_JOIN == "true" && \
		$SCAN_PAGES == $JOIN_PAGES && \
		$SCAN_USERVISITS == $JOIN_USERVISITS ]]
	then
		m_echo "Reusing $INPUT_JOIN as input for Scan"
		export INPUT_SCAN=$INPUT_JOIN
	else
		m_echo "Generating Scan data: ${SCAN_PAGES} pages, ${SCAN_USERVISITS} uservisits"
		OPTIONS="-t hive \
			-n ${INPUT_SCAN} \
			-m ${MAPPERS_NUMBER} \
			-r ${REDUCERS_NUMBER} \
			-p ${SCAN_PAGES} \
			-v ${SCAN_USERVISITS} \
			-o sequence"

		${HADOOP_EXECUTABLE} jar ${DATAGEN_JAR} ${OPTIONS}
	fi
fi

if [[ $GEN_COMMAND == "true" ]]
then
	if [[ -n "$PREPARE_COMMAND" ]]
	then
		m_echo "Preparing Command benchmark: $PREPARE_COMMAND"
	
		bash -c "$PREPARE_COMMAND"
	fi
fi
