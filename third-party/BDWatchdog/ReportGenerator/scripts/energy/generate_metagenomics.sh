#!/usr/bin/env bash

function baseline1 {
    cp conf/templates/energy/metagenomics/report_generator_config.ini conf/report_generator_config.ini
    sed -i 's/__XLIM__/XLIM/g' conf/report_generator_config.ini
    sed -i 's/{XLIM}/aux_user0:3300,pre_user0:3300,comp_user0:1600/g' conf/report_generator_config.ini
    sed -i 's/__PRINT_ENERGY_MAX__/PRINT_ENERGY_MAX/g' conf/report_generator_config.ini
    sed -i 's/{PRINT_ENERGY_MAX}/false/g' conf/report_generator_config.ini
    bash scripts/generate_report.sh 00:00_MG
    bash scripts/generate_report.sh 01:00_MG
    bash scripts/generate_report.sh 02:00_MG
    bash scripts/generate_report.sh 03:00_MG
}

function serverless1 {
    cp conf/templates/energy/metagenomics/report_generator_config.ini conf/report_generator_config.ini
    sed -i 's/__XLIM__/XLIM/g' conf/report_generator_config.ini
    sed -i 's/{XLIM}/aux_user0:3300,pre_user0:3300,comp_user0:1600/g' conf/report_generator_config.ini
    sed -i 's/__PRINT_ENERGY_MAX__/PRINT_ENERGY_MAX/g' conf/report_generator_config.ini
    sed -i 's/{PRINT_ENERGY_MAX}/true/g' conf/report_generator_config.ini
    bash scripts/generate_report.sh 10:00_MG
    bash scripts/generate_report.sh 11:00_MG
    bash scripts/generate_report.sh 12:00_MG
}

function baseline2 {
    cp conf/templates/energy/metagenomics/report_generator_config.ini conf/report_generator_config.ini
    sed -i 's/__XLIM__/XLIM/g' conf/report_generator_config.ini
    sed -i 's/{XLIM}/aux_user0:3300,pre_user0:3300,comp_user0:1700/g' conf/report_generator_config.ini
    sed -i 's/__PRINT_ENERGY_MAX__/PRINT_ENERGY_MAX/g' conf/report_generator_config.ini
    sed -i 's/{PRINT_ENERGY_MAX}/false/g' conf/report_generator_config.ini
    #bash scripts/generate_report.sh 20:00_MG
    #bash scripts/generate_report.sh 21:00_MG
    #bash scripts/generate_report.sh 22:00_MG
    bash scripts/generate_report.sh 23:00_MG
    #bash scripts/generate_report.sh 24:00_MG
    #bash scripts/generate_report.sh 25:00_MG
    #bash scripts/generate_report.sh 26:00_MG
    #bash scripts/generate_report.sh 27:00_MG
}



function serverless2 {
    cp conf/templates/energy/metagenomics/report_generator_config.ini conf/report_generator_config.ini
    sed -i 's/__XLIM__/XLIM/g' conf/report_generator_config.ini
    sed -i 's/{XLIM}/aux_user0:3300,pre_user0:3300,comp_user0:1700/g' conf/report_generator_config.ini
    sed -i 's/__PRINT_ENERGY_MAX__/PRINT_ENERGY_MAX/g' conf/report_generator_config.ini
    sed -i 's/{PRINT_ENERGY_MAX}/true/g' conf/report_generator_config.ini
    #bash scripts/generate_report.sh 30:00_MG
    #bash scripts/generate_report.sh 31:00_MG
    #bash scripts/generate_report.sh 32:00_MG
    #bash scripts/generate_report.sh 33:00_MG
    #bash scripts/generate_report.sh 34:00_MG
    #bash scripts/generate_report.sh 35:00_MG
    #bash scripts/generate_report.sh 36:00_MG
    bash scripts/generate_report.sh 37:00_MG
    bash scripts/generate_report.sh 38:00_MG
    #bash scripts/generate_report.sh 39:00_MG

}

cp conf/templates/energy/metagenomics/timestamping_config.ini conf/timestamping_config.ini
baseline2
serverless2




