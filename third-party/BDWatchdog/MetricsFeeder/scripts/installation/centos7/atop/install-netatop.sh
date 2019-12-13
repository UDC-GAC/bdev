#!/usr/bin/env bash
# Install netatop

# Download and uncompress netatop
wget https://www.atoptool.nl/download/netatop-1.0.tar.gz
tar xvf netatop-1.0.tar.gz
cd netatop-1.0

# Compile and install
make
make install

# Load the module netatop
modprobe netatop

# Return
cd ..

# Clean
rm -R netatop-1.0.tar.gz
rm -Rf netatop-1.0


