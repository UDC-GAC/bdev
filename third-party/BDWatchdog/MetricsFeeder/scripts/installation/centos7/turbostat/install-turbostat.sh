#!/usr/bin/env bash
KERNEL_VERSION=`uname -r`

# Install turbostat
yum install -y kernel-tools-$KERNEL_VERSION
yum install -y kernel-debug-devel-$KERNEL_VERSION
yum install -y kernel-devel-$KERNEL_VERSION

