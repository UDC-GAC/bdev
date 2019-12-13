#!/usr/bin/env bash
# This script will
#	- load the MSR (Model Specific Registers) of the CPU, present in x86 instruction sets
#	- make MSR readable
#	- allow turbostat to be executable by users for the currently used kernel

KERNEL_VERSION=`uname -r | cut -d "-" -f 1,2`

sudo modprobe msr
sudo chmod +r /dev/cpu/*/msr
sudo setcap cap_sys_rawio=ep /usr/lib/linux-tools-${KERNEL_VERSION}*/turbostat
