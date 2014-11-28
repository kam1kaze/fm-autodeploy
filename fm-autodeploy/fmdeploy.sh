#!/bin/bash

# Enable strict mode
set -euo pipefail

# Reset locale settings
export LC_ALL=C

scriptdir=$(cd $(dirname "$0") && pwd)
scriptname=$(basename "$0")

# Include the script with handy functions to operate VMs and Virtual networking
source $scriptdir/config.sh
source $scriptdir/functions/vm.sh
source $scriptdir/functions/network.sh
source $scriptdir/functions/product.sh

function usage {
  echo "Usage: $scriptname prepare|destroy|fuel|slaves (-e env-name-prefix ) (-f fuel-iso-path) (-s cluster-size)" >&2
  exit 1
}

# Save action and go to params
action=${1:-NONE}
[[ $# > 0 ]] && shift

# Parse params
while getopts ":e:f:s:" opt; do
  case $opt in
    e)
      env_name_prefix=$OPTARG
      ;;
    f)
      fuel_path=$OPTARG
      ;;
    s)
      cluster_size=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      usage
      ;;
  esac
done

# Parse actions
case $action in
  prepare)
    script="prepare-environment.sh"
    ;;
  destroy)
    script="destroy-environment.sh"
    ;;
  fuel)
    script="master-node-create-and-install.sh"
    ;;
  slaves)
    script="slave-nodes-create-and-boot.sh"
    ;;
  NONE)
    usage
    ;;
  * )
    echo "ERROR: Unknown action: $action" >&2
    usage
    ;;
esac

# Initial checks and generate variables
source $scriptdir/actions/init.sh

# Do a job
source $scriptdir/actions/$script

echo "Done"
exit 0
