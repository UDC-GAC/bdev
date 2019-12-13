#!/usr/bin/env bash
source $HOME/development/BDWatchdog/set_pythonpath.sh
export REPORT_GENERATOR_PATH=$BDWATCHDOG_PATH/ReportGenerator

echo "Generating report for experiment $1"
mkdir -p $REPORT_GENERATOR_PATH/pandoc_reports/$1
cd $REPORT_GENERATOR_PATH/pandoc_reports/$1
python3 ${REPORT_GENERATOR_PATH}/src/report_generator.py $1 > $1.txt
if [[ $? -eq 0 ]]
then
    pandoc $1.txt --latex-engine=xelatex --variable=fontsize:8pt --number-sections --toc --template $REPORT_GENERATOR_PATH/templates/simple_report.template -o $1.pdf
    if [[ $? -eq 0 ]]
    then
        echo "Successfully generated report"
    fi
    rm *.eps
fi
cd $REPORT_GENERATOR_PATH

