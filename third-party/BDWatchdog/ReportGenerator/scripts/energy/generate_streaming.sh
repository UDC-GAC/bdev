#!/usr/bin/env bash
cp conf/templates/energy/streaming/timestamping_config.ini conf/timestamping_config.ini

cp conf/templates/energy/streaming/report_generator_config.ini conf/report_generator_config.ini
sed -i 's/__XTICKS_STEP__/XTICKS_STEP/g' conf/report_generator_config.ini
sed -i 's/{XTICKS_STEP}/500/g' conf/report_generator_config.ini
sed -i 's/__XLIM__/XLIM/g' conf/report_generator_config.ini
sed -i 's/{XLIM}/default:3700/g' conf/report_generator_config.ini
sed -i 's/__YLIM__/YLIM/g' conf/report_generator_config.ini
sed -i 's/{YLIM}/cpu:default:6000,energy:default:900/g' conf/report_generator_config.ini

bash scripts/generate_report.sh 00:00_ST
bash scripts/generate_report.sh 01:00_ST #CHOSEN
bash scripts/generate_report.sh 02:00_ST
bash scripts/generate_report.sh 03:00_ST
bash scripts/generate_report.sh 04:00_ST
bash scripts/generate_report.sh 05:00_ST

