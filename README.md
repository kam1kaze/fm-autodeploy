Mirantis Openstack Platform autodeployment
==============

Usage:
fmdeploy.sh prepare|destroy|fuel|slaves (-e env-name-prefix ) (-f fuel-iso-path) (-s cluster-size)

prepare   prepare environment (check netowrk configuration, create virtual networks)
fuel      create and boot VM to deploy fuel master from iso)
slaves    create and boot VMs
destroy   clear environment

"fuel" and "slaves" actions are repeatable. They can be used multiple times, in this case the old VMs will be deleted.
