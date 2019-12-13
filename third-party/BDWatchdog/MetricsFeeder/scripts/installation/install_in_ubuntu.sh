#!/usr/bin/env bash
apt update
bash scripts/installation/ubuntu/dependencies/install-dependencies.sh
bash scripts/installation/ubuntu/python-dependencies/install-python-dependencies.sh
bash scripts/installation/ubuntu/atop/install-atop.sh
#bash atop/install-netatop.sh
bash scripts/installation/ubuntu/turbostat/install-turbostat.sh
