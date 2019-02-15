#!/bin/bash

kernel_image_name=bm-deploy-kernel
ramdisk_image_name=bm-deploy-ramdisk

OPTS=$(getopt -o 'k:r:' --long '--ramdisk:,--kernel:' -n "${0##*/}" -- "$@")
[[ $? -eq 0 ]] || exit 1

eval set -- "$OPTS"
unset OPTS
while true; do
	case "$1" in
		(-k|--kernel)
			kernel_image_name=$2
			shift 2
			;;
		(-r|--ramdisk)
			ramdisk_image_name=$2
			shift 2
			;;
		(--)	shift
			break
			;;
	esac
done

if [ $# -ne 3 ]; then
	echo "${0##*/}: usage: ${0##*/} [-k <kernel>] [-r <ramdisk>] name ipmi_port mac_addr" >&2
	exit 2
fi

kernel_uuid=$(openstack image show $kernel_image_name -c id -f value)
if [[ $? -ne 0 ]]; then
	echo "ERROR: unable to find kernel image named $kernel_image_name" >&2
	exit 1
fi

ramdisk_uuid=$(openstack image show $ramdisk_image_name -c id -f value)
if [[ $? -ne 0 ]]; then
	echo "ERROR: unable to find ramdisk image named $ramdisk_image_name" >&2
	exit 1
fi

openstack baremetal node create --name "$1" \
	--driver ipmi \
	--driver-info ipmi_address=192.168.122.1 \
	--driver-info ipmi_port="$2" \
	--driver-info ipmi_username=admin \
	--driver-info ipmi_password=password \
	--driver-info deploy_kernel=$kernel_uuid \
	--driver-info deploy_ramdisk=$ramdisk_uuid \
	--driver-info provisioning_network=provisioning \
	--driver-info cleaning_network=provisioning \
	--resource-class baremetal

node_uuid=$(openstack baremetal node show $1 -f value -c uuid)
if [[ $? -ne 0 ]]; then
	echo "ERROR: unable to look up uuid for node $1" >&2
	exit 1
fi

openstack baremetal port create $3 --node $node_uuid
