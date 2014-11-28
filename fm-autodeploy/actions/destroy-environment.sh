#!/bin/bash

# Delete all VMs from the previous Fuel Web installation
delete_vms_multiple $env_name_prefix

# Delete previous networks
delete_previous_networks

# Delete FUEL iso
rm -vf $default_fuel_path
