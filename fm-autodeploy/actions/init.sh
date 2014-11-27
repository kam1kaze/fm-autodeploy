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

# Generate network params
for ip in 10.20.100.1 172.16.1.1; do
#for ip in 10.20.0.1 240.0.1.1 172.16.0.1; do
  host_net_name[$idx]="${env_name_prefix}${idx}"
  host_net_bridge[$idx]="virbr${idx}"
  host_nic_ip[$idx]="$ip"
  host_nic_mask[$idx]="255.255.255.0"
  idx_list+=" $idx"
  idx=$((idx+1))
done

# Create directory for iso disks
mkdir -p $iso_storage

default_fuel_path="$iso_storage/${env_name_prefix}fuel.iso"
