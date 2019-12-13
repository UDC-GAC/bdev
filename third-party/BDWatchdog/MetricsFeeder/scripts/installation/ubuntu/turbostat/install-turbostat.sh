#!/usr/bin/env bash
KERNEL_VERSION=`uname -r`

# Install turbostat
sudo apt install -y linux-tools-$KERNEL_VERSION
sudo apt install -y linux-cloud-tools-$KERNEL_VERSION
sudo apt install -y linux-tools-generic
sudo apt install -y linux-cloud-tools-generic

echo ""
echo "If you are going to use turbostat, remember to set the required priviledges for unpriviledged users"
echo "'bash scripts/allow_priviledges/allow_turbostat.sh'"
