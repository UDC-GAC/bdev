#!/usr/bin/env bash

cp conf/templates/serverless_revision/microbenchmarks/report_generator_config.ini conf/report_generator_config.ini
cp conf/templates/serverless_revision/microbenchmarks/timestamping_config.ini conf/timestamping_config.ini
#bash scripts/generate_report.sh 00:00_PR
#bash scripts/generate_report.sh 01:00_PR
#bash scripts/generate_report.sh 03:00_PR
bash scripts/generate_report.sh 02:00_PR #CHOSEN

cp conf/templates/serverless_revision/streaming/report_generator_config.ini conf/report_generator_config.ini
cp conf/templates/serverless_revision/streaming/timestamping_config.ini conf/timestamping_config.ini
#bash scripts/generate_report.sh 00:00_FW
#bash scripts/generate_report.sh 01:00_FW
bash scripts/generate_report.sh 02:00_FW #CHOSEN

cp conf/templates/serverless_revision/hybrid/report_generator_config.ini conf/report_generator_config.ini
cp conf/templates/serverless_revision/hybrid/timestamping_config.ini conf/timestamping_config.ini
#bash scripts/generate_report.sh 00:00_HYBRID
#bash scripts/generate_report.sh 01:00_HYBRID
#bash scripts/generate_report.sh 02:00_HYBRID
bash scripts/generate_report.sh 03:00_HYBRID #CHOSEN

cp conf/templates/serverless_revision/concurrent/report_generator_config.ini conf/report_generator_config.ini
cp conf/templates/serverless_revision/concurrent/timestamping_config.ini conf/timestamping_config.ini
#bash scripts/generate_report.sh 00:00_CONCURRENT
bash scripts/generate_report.sh 01:00_CONCURRENT #CHOSEN
