#!/bin/sh

$HADOOP_EXECUTABLE fs ${RMR} $OUTPUT_BAYES

run_benchmark "${MAHOUT_HOME}/bin/mahout seq2sparse \
		-i ${INPUT_BAYES} -o ${OUTPUT_BAYES}/vectors \
		-lnorm -nv -wt tfidf -ng ${BAYES_NGRAMS} \
		--numReducers $REDUCERS_NUMBER ; \
		${MAHOUT_HOME}/bin/mahout trainnb \
		-i ${OUTPUT_BAYES}/vectors/tfidf-vectors -o ${OUTPUT_BAYES}/model \
		-li ${OUTPUT_BAYES}/labelindex -ow --tempDir ${OUTPUT_BAYES}/temp"

if [ $(cat $TMPLOGFILE | grep -i -E 'job failed|FinalApplicationStatus=FAILED|Exception in thread "main"' | wc -l) != "0" ]
then
	ELAPSED_TIME="FAILED"
fi
