#!/bin/bash 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get the first available ISO from the directory 'iso'
iso_path=`ls -1 $SCRIPT_DIR/iso/*.iso 2>/dev/null | head -1`

# Every Fuel Web machine name will start from this prefix  
env_name_prefix=fw51-jenkins-

vm_disk_path="$SCRIPT_DIR/images"

#Use bridge interface: 0 - false, 1 - true. If you have existing bridge with pysical NIC you can use it for VMs. Bridged network will be created as eth1 in guest OS.
use_bridge=0
#Bridge name (if use_bridge=1)
br_name="br100"
# If you need to automatically configure network interface on master node after its deployment, follow these steps:
# 1. set 'iface' name (example: iface="eth1.325")
# 2. uncomment ./actions/create_pub_net_master.sh script in launch.sh
# 3. create ./ifcfg-${iface} config file with needed settings for interfae
iface="eth1"

#networks definition: id, list of host IP's for ech network. The first network will be used for provisioning
idx=150
netmask=255.255.255.0
for ip in 10.20.100.1 172.16.1.1; do
#for ip in 10.20.0.1 240.0.1.1 172.16.0.1; do
  host_net_name[$idx]="${env_name_prefix}${idx}"
  host_net_bridge[$idx]="virbr${idx}"
  host_nic_ip[$idx]="$ip"
  host_nic_mask[$idx]="255.255.255.0"
  idx_list+=" $idx"
  idx=$((idx+1))
done

# Master node settings
vm_master_cpu_cores=1
vm_master_memory_mb=1224
vm_master_disk_mb=40480

# These settings will be used to check if master node has installed or not.
# If you modify networking params for master node during the boot time
#   (i.e. if you pressed Tab in a boot loader and modified params),
#   make sure that these values reflect that change.
vm_master_ip=10.20.100.2
vm_master_username=root
vm_master_password=r00tme
vm_master_prompt='root@fuelweb ~]#'

domain_name="mirtest.net"