#!/usr/bin/env bash
cp conf/templates/energy/microbenchmarks/timestamping_config.ini conf/timestamping_config.ini

cp conf/templates/energy/microbenchmarks/report_generator_config.ini conf/report_generator_config.ini
sed -i 's/__XTICKS_STEP__/XTICKS_STEP/g' conf/report_generator_config.ini
sed -i 's/{XTICKS_STEP}/200/g' conf/report_generator_config.ini
sed -i 's/__XLIM__/XLIM/g' conf/report_generator_config.ini
sed -i 's/{XLIM}/default:2000/g' conf/report_generator_config.ini
sed -i 's/__PRINT_ENERGY_MAX__/PRINT_ENERGY_MAX/g' conf/report_generator_config.ini
sed -i 's/{PRINT_ENERGY_MAX}/false/g' conf/report_generator_config.ini
sed -i 's/{__DOWNSAMPLE__}/DOWNSAMPLE/g' conf/report_generator_config.ini
sed -i 's/{DOWNSAMPLE}/10/g' conf/report_generator_config.ini
bash scripts/generate_report.sh 00:00_EPR #CHOSEN


cp conf/templates/energy/microbenchmarks/report_generator_config.ini conf/report_generator_config.ini
sed -i 's/__XTICKS_STEP__/XTICKS_STEP/g' conf/report_generator_config.ini
sed -i 's/{XTICKS_STEP}/200/g' conf/report_generator_config.ini
sed -i 's/__XLIM__/XLIM/g' conf/report_generator_config.ini
sed -i 's/{XLIM}/default:2000/g' conf/report_generator_config.ini
sed -i 's/__PRINT_ENERGY_MAX__/PRINT_ENERGY_MAX/g' conf/report_generator_config.ini
sed -i 's/{PRINT_ENERGY_MAX}/true/g' conf/report_generator_config.ini
sed -i 's/{__DOWNSAMPLE__}/DOWNSAMPLE/g' conf/report_generator_config.ini
sed -i 's/{DOWNSAMPLE}/10/g' conf/report_generator_config.ini
#bash scripts/generate_report.sh 01:00_EPR
bash scripts/generate_report.sh 02:00_EPR #CHOSEN
#bash scripts/generate_report.sh 03:00_EPR


cp conf/templates/energy/microbenchmarks/report_generator_config.ini conf/report_generator_config.ini
sed -i 's/__XTICKS_STEP__/XTICKS_STEP/g' conf/report_generator_config.ini
sed -i 's/{XTICKS_STEP}/200/g' conf/report_generator_config.ini
sed -i 's/__XLIM__/XLIM/g' conf/report_generator_config.ini
sed -i 's/{XLIM}/default:1200/g' conf/report_generator_config.ini
sed -i 's/__PRINT_ENERGY_MAX__/PRINT_ENERGY_MAX/g' conf/report_generator_config.ini
sed -i 's/{PRINT_ENERGY_MAX}/false/g' conf/report_generator_config.ini
sed -i 's/{__DOWNSAMPLE__}/DOWNSAMPLE/g' conf/report_generator_config.ini
sed -i 's/{DOWNSAMPLE}/5/g' conf/report_generator_config.ini
bash scripts/generate_report.sh 00:00_EKM #CHOSEN

cp conf/templates/energy/microbenchmarks/report_generator_config.ini conf/report_generator_config.ini
sed -i 's/__XTICKS_STEP__/XTICKS_STEP/g' conf/report_generator_config.ini
sed -i 's/{XTICKS_STEP}/200/g' conf/report_generator_config.ini
sed -i 's/__XLIM__/XLIM/g' conf/report_generator_config.ini
sed -i 's/{XLIM}/default:1200/g' conf/report_generator_config.ini
sed -i 's/__PRINT_ENERGY_MAX__/PRINT_ENERGY_MAX/g' conf/report_generator_config.ini
sed -i 's/{PRINT_ENERGY_MAX}/true/g' conf/report_generator_config.ini
sed -i 's/{__DOWNSAMPLE__}/DOWNSAMPLE/g' conf/report_generator_config.ini
sed -i 's/{DOWNSAMPLE}/5/g' conf/report_generator_config.ini
bash scripts/generate_report.sh 01:00_EKM #CHOSEN
#bash scripts/generate_report.sh 02:00_EKM




