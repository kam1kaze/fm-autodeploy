#!/bin/bash

#
# This script creates a master node for the product, launches its installation,
# and waits for its completion
#

# parse fuel iso_path params
if [[ -z ${param_fuel_path:-} ]]; then
  # param does not exist
  iso_path=$default_fuel_path
elif [[ ${param_fuel_path,,} =~ ^(https?|ftp|file):// ]]; then
  # param is link
  wget $param_fuel_path -O $default_fuel_path 2>&1 \
    | gawk --posix '$7 ~ /^[0-9]{1,3}%$/{if(s!=$7)print;s=$7;next}{print}' \
    || { echo "ERROR: Cannot downloda FUEL iso from $param_fuel_path" >&2; exit 1; }
  iso_path=$default_fuel_path
else
  # param is regular path
 [[ -f "$param_fuel_path" ]] || { echo "ERROR: Cannot find FUEL iso in $param_fuel_path" >&2; exit 1; }
 iso_path=$param_fuel_path
fi

# Create master node for the product
name="${env_name_prefix}master"
first_net="${host_net_name[`echo ${!host_net_name[*]} | cut -d " " -f 1`]}"
first_ip="${host_nic_ip[`echo ${!host_nic_ip[*]} | cut -d " " -f 1`]}"
is_vm_present $name && delete_vm $name
echo

# Adding bridge NIC if any
if [[ $use_bridge == 1 ]]; then
   BRIDGE_NET="-w bridge=$br_name,model=virtio"
else
   BRIDGE_NET=""
fi

# Creating disk for master node
#vm_disk_path="$(get_vm_base_path)"
#vm_disk_path="~jenkins/images"
disk_name="${name}_0"
disk_filename="${disk_name}.qcow2"

#create_pool $vm_disk_path
#qemu-img create -f qcow2 -o preallocation=metadata ${vm_disk_path}/${disk_filename} ${vm_master_disk_mb}M

# Add other host-only nics to VM
HOST_NETS=""
for i in `seq 2 ${#host_net_name[*]}`
do
  HOST_NETS="$HOST_NETS -w network=${host_net_name[`echo ${!host_net_name[*]} | cut -d " " -f $i`]},model=virtio "
done

#echo "virt-install --connect qemu:///system --hvm --name $name --ram $vm_master_memory_mb --vcpus $vm_master_cpu_cores --disk ${vm_disk_path}/${disk_filename},bus=virtio,cache=none,format=qcow2,io=native -w network=$first_net,model=virtio $BRIDGE_NET $HOST_NETS --disk ${iso_path},device=cdrom --autostart --graphics vnc --location $(pwd) --extra-args \"initrd=initrd.img biosdevname=0 ks=cdrom:/ks.cfg ip=$vm_master_ip gw=$first_ip dns1=8.8.8.8 netmask=255.255.255.0 hostname=fuelweb.domain.tld\""

virt-install --connect qemu:///system --noautoconsole --hvm --name $name --ram $vm_master_memory_mb --vcpus $vm_master_cpu_cores --disk pool=default,size=${vm_master_disk_gb},bus=virtio,cache=none,format=qcow2,io=native -w network=$first_net,model=virtio $BRIDGE_NET $HOST_NETS --disk ${iso_path},device=cdrom --autostart --graphics vnc --location ${scriptdir}/linux --extra-args "initrd=initrd.img biosdevname=0 ks=cdrom:/ks.cfg ip=$vm_master_ip gw=$first_ip dns1=8.8.8.8 netmask=255.255.255.0 hostname=fuelweb.${domain_name}"

# Start virtual machine with the master node
echo "Waiting for OS installation on Master node"
sleep 5
while is_vm_running $name; do
	sleep 5
done
echo "OS has been installed, rebooting the master node"
virsh start $name
ssh-keygen -R $vm_master_ip
# Wait until the machine gets installed and Puppet completes its run
wait_for_product_vm_to_install $vm_master_ip $vm_master_username $vm_master_password "$vm_master_prompt"

# Report success
echo
echo "Master node has been installed."
