git clone https://github.com/jvm-profiling-tools/perf-map-agent
cd perf-map-agent
cmake .
make
cd ..
sudo mkdir -p /usr/lib/jvm/
sudo cp -R perf-map-agent /usr/lib/jvm/perf-map-agent
rm -Rf perf-map-agent
