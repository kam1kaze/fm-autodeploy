#!/bin/bash

# Enable strict mode
set -euo pipefail

# Reset locale settings
export LC_ALL=C

scriptdir=$(cd $(dirname "$0") && pwd)
scriptname=$(basename "$0")

# Include the script with handy functions to operate VMs and Virtual networking
source $scriptdir/functions/vm.sh
source $scriptdir/functions/network.sh
source $scriptdir/functions/product.sh

function usage {
  echo "Usage: $scriptname prepare|destroy|fuel|slaves (-f fuel-iso-path) (-c config_path)" >&2
  exit 1
}

# Save action and go to params
action=${1:-NONE}
[[ $# > 0 ]] && shift

# Parse params
while getopts ":f:c:" opt; do
  case $opt in
    f)
      param_fuel_path=$OPTARG
      ;;
    c)
      param_config_path=$OPTARG
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

# Include config
config_path=${param_config_path:-$scriptdir/config.sh}
if [[ -f $config_path ]]; then
  source $config_path
else
  echo "ERROR: cannot find config file $config_path" >&2
  exit 1
fi

# Initial checks and generate variables
source $scriptdir/actions/init.sh

# Do a job
source $scriptdir/actions/$script

echo "Done"
exit 0
