#!/usr/bin/env bash
# Run in the opentsdb installation folder

# SYSTEM POWER CONSUMPTION AND TEMP
	#Core
	./build/tsdb mkmetric sys.core.temp
	
	#Chip (processor or package)
	./build/tsdb mkmetric sys.cpu.temp
	./build/tsdb mkmetric sys.cpu.energy
	
	#System
	./build/tsdb mkmetric sys.processors.temp
	./build/tsdb mkmetric sys.processors.energy

# SYSTEM METRICS
	#cpu
	./build/tsdb mkmetric sys.cpu.kernel
	./build/tsdb mkmetric sys.cpu.user
	./build/tsdb mkmetric sys.cpu.idle
	./build/tsdb mkmetric sys.cpu.wait

	#CPU
	./build/tsdb mkmetric sys.cpu.usage

	#DISK
	./build/tsdb mkmetric sys.disk.usage
	./build/tsdb mkmetric sys.disk.read.ios
	./build/tsdb mkmetric sys.disk.read.mb
	./build/tsdb mkmetric sys.disk.write.ios
	./build/tsdb mkmetric sys.disk.write.mb

	#MEM
	./build/tsdb mkmetric sys.mem.free
	./build/tsdb mkmetric sys.mem.usage

	#NET
	./build/tsdb mkmetric sys.net.in.mb
	./build/tsdb mkmetric sys.net.out.mb
	./build/tsdb mkmetric sys.net.usage

	#INFINIBAND
	./build/tsdb mkmetric sys.net.in.mb
	./build/tsdb mkmetric sys.net.out.mb

# PROCESS METRICS
	#CPU
	./build/tsdb mkmetric proc.cpu.user
	./build/tsdb mkmetric proc.cpu.kernel

	#DISK
	./build/tsdb mkmetric proc.disk.reads.mb
	./build/tsdb mkmetric proc.disk.writes.mb

	#MEM
	./build/tsdb mkmetric proc.mem.virtual
	./build/tsdb mkmetric proc.mem.resident
	./build/tsdb mkmetric proc.mem.swap
	
	#SWAP
	./build/tsdb mkmetric sys.swap.free
	
	#NET
	./build/tsdb mkmetric proc.net.tcp.out.mb
	./build/tsdb mkmetric proc.net.tcp.out.packets
	./build/tsdb mkmetric proc.net.tcp.in.mb
	./build/tsdb mkmetric proc.net.tcp.in.packets
	./build/tsdb mkmetric proc.net.udp.out.mb
	./build/tsdb mkmetric proc.net.udp.out.packets
	./build/tsdb mkmetric proc.net.udp.in.mb
	./build/tsdb mkmetric proc.net.udp.in.packets

	
