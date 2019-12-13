#!/usr/bin/env bash
sudo apt-get install libpcap-dev ncurses-dev
rm -Rf bin-nethogs
git clone https://github.com/raboof/nethogs bin-nethogs
cd bin-nethogs
make
cd ..
mkdir -p bin/nethogs
cp bin-nethogs/src/nethogs bin/nethogs/nethogs
rm -Rf bin-nethogs
echo ""
echo "If you are going to use nethogs, remember to set the required priviledges for unpriviledged users"
echo "'bash scripts/allow_priviledges/allow_nethogs.sh'"