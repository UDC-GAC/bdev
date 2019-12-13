#!/usr/bin/env bash
# Download and uncompress netatop
wget http://www.atoptool.nl/download/netatop-1.0.tar.gz
tar xvf netatop-1.0.tar.gz
cd netatop-1.0/

# Compile and install
make
sudo make install

# Load the module netatop
sudo modprobe netatop

# Return
cd ..

# Clean
rm -R netatop-1.0.tar.gz
sudo rm -Rf netatop-1.0


