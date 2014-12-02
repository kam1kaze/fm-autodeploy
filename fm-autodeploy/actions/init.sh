#!/bin/bash

# Check for expect
echo -n "Checking for 'expect'... "
expect -v >/dev/null 2>&1 || { echo >&2 "'expect' is not available in the path, but it's required. Please install 'expect' package. Aborting."; exit 1; }
echo "OK"

# Check for virsh
echo -n "Checking for 'virsh'... "
virsh -v >/dev/null 2>&1 || { echo >&2 "'virsh' is not available in the path, but it's required. Please install 'libvirt' package. Aborting."; exit 1; }
echo "OK"

#Check for qemu-img
#echo -n "Checking for 'qemu-img'... "
#which qemu-img >/dev/null && { echo >&2 "OK"; } || { echo  >&2 "'qemu-img' tool is not installed."; exit 1; }

# Default path to ISO
default_fuel_path="./${env_name_prefix}fuel.iso"
