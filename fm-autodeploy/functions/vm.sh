#!/bin/bash

# This file contains the functions to manage VMs in through VirtualBox CLI

get_vms_running() {
    virsh -q list | awk '{print $2}'
}

get_vms_present() {
    virsh -q list --all | awk '{print $2}'
}

is_vm_running() {
    name=$1
    list=$(get_vms_running)

    # Check that the list of running VMs contains the given VM
    if [[ $list = *$name* ]]; then
        return 0
    else
        return 1
    fi
}

is_vm_present() {
    name=$1
    list=$(get_vms_present)

    # Check that the list of VMs contains the given VM
    if [[ $list = *$name* ]]; then
        return 0
    else
        return 1
    fi
}

create_vm() {
    name=$1
    nic=$2
    cpu_cores=$3
    memory_mb=$4
    disk_mb=$5
    HYPERVISOR="qemu:///system"

    # Create virtual machine with the right name and type (assuming CentOS) 
    virt-install --connect=${HYPERVISOR} --name=${name} --arch=x86_64 --vcpus=${cpu_cores} --ram=${memory_mb} --os-type=linux --os-variant=rhel6 --hvm --accelerate --vnc --noautoconsole --keymap=en-us --boot network,cdrom,hd --disk device=cdrom --nonetworks --cpu host --noautoconsole

    virsh destroy $name

    # Configure main network interface
    add_nic_to_vm $name $nic

    # Create and attach the main hard drive
    add_disk_to_vm $name 0 $disk_mb
}

add_nic_to_vm() {
    name=$1
    nic=$2
    echo "Adding NIC to $name and bridging with host NIC $nic..."

    # Configure network interfaces
    virsh attach-interface ${name} --type network --source ${nic} --persistent --model virtio
}

add_br_nic_to_vm() {
    name=$1
    bridge=$2
    echo "Adding Bridge to $name"

    # Configure network interfaces
    virsh attach-interface ${name} --type bridge --source ${bridge} --persistent --model virtio
}

add_disk_to_vm() {
    vm_name=$1
    port=$2
    disk_mb=$3
    case $port in 
	1)
	  target="vdb"
	;;
	2)
	  target="vdc"
	;;
	*)
	  target="vda"
	;;
    esac

    echo "Adding disk to $vm_name, with size $disk_mb Mb..."

    #vm_disk_path="$(get_vm_base_path)"
    disk_name="${vm_name}_${port}.qcow2"
    #disk_filename="${disk_name}.qcow2"
    #qemu-img create -f qcow2 -o preallocation=metadata ${vm_disk_path}/${disk_filename} ${disk_mb}M
    virsh vol-create-as default ${disk_name} ${disk_mb}M --format qcow2
    # adding sata disk via xml, as attach-disk can't specify bus=sata
    #virsh attach-disk ${vm_name} --source ${vm_disk_path}/${disk_filename} --target ${target} --subdriver qcow2 --persistent
#    echo "Creating network template"
#    cat <<EOF > /tmp/disk_device.xml
#    <disk type='file' device='disk'>
#      <driver name='qemu' type='qcow2' cache='unsafe'/>
#      <source file="${vm_disk_path}/${disk_filename}"/>
#      <target dev="$target" bus='virtio'/>
#    </disk>
#EOF
#    virsh attach-device $vm_name /tmp/disk_device.xml --persistent
    disk_path=`virsh vol-path ${disk_name} --pool default`
    virsh attach-disk ${vm_name} --source ${disk_path} --target ${target} --subdriver qcow2 --persistent 
}

delete_vm() {
    name=$1

    # Power off VM, if it's running
    if is_vm_running $name; then
	echo "Stopping VM $name"
        virsh destroy $name
    fi

    # Deleting attached volumes
    virsh -q domblklist $name | awk '/^vda/{print $2}' | while read volume; do
        virsh vol-delete $volume
    done

    # Undefining VM
    echo "Deleting existing virtual machine $name..."
    virsh undefine $name
}

delete_vms_multiple() {
    name_prefix=$1
    list=$(get_vms_present)

    # Loop over the list of VMs and delete them, if its name matches the given refix 
    for name in $list; do
        if [[ $name == $name_prefix* ]]; then
            echo "Found existing VM: $name. Deleting it..."
            delete_vm $name 
        fi
    done
}

start_vm() {
    name=$1

    virsh start $name
}

start_vm_paused() {
    name=$1

    virsh start $name --paused
}

resume_vm() {
    name=$1
    
    virsh resume $name
}

mount_iso_to_vm() {
    name=$1
    iso_path=$2
 
    # Mount ISO to the VM
    echo "Mounting ISO ${iso_path} to ${name}"
    #virsh change-media ${name} hdc ${iso_path} --config
    virsh attach-disk $name ${iso_path} hdc  --type cdrom --mode readonly
}

enable_network_boot_for_vm() {
    # The function is not needed actually. The boot order is specified during VM creation.
    name=$1

    # Set the right boot device
    virsh dumpxml ${name} > /tmp/${name}.xml
    # sed 
}

reset_vm() {
    # another unused function :)
    name=$1

    # Power reset on VM
    virsh reset $name
}
