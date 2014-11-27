# Mirantis Openstack Platform autodeployment

## Install
Copy config.exmaple.sh to config.sh. Make necessary changes.

## Usage
`fmdeploy.sh prepare|destroy|fuel|slaves (-e env-name-prefix ) (-f fuel-iso-path) (-s cluster-size)`

### Actions
 * **prepare** - prepare environment (check netowrk configuration, create virtual networks)
 * **fuel** - create and boot VM to deploy fuel master from iso)
 * **slaves** - create and boot VMs
 * **destroy** - clear environment

### Params
 * **-e** - prefix for all kvm objects
 * **-f** - path to FUEL iso, can be regular path or URL (https/http/ftp)
 * **-s** - how many VMs should be created (exclude FUEL node)

**fuel** and **slaves** actions are repeatable. They can be used multiple times, in this case the old VMs will be deleted.
