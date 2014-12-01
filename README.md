# Mirantis Openstack Platform autodeployment

## Install
Copy config.exmaple.sh to config.sh. Make necessary changes.

## Usage
`fmdeploy.sh prepare|destroy|fuel|slaves (-f fuel-iso-path) (-c config_path)`

### Actions
 * **prepare** - prepare environment (check netowrk configuration, create virtual networks)
 * **fuel** - create and boot VM to deploy fuel master from iso)
 * **slaves** - create and boot VMs
 * **destroy** - clear environment

### Params
 * **-f** - path to FUEL iso, can be regular path or URL (https/http/ftp) (default: $PWD/${env-name-prefix}-fuel.iso)
 * **-c** - path to config file (default: ${SCRIPT_DIR}/config.sh)

**fuel** and **slaves** actions are repeatable. They can be used multiple times, in this case the old VMs will be deleted.
