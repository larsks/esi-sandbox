#!/bin/bash

kernel_image_name=${IRONIC_DEPLOY_KERNEL:-bm-deploy-kernel}
ramdisk_image_name=${IRONIC_DEPLOY_RAMDISK:-bm-deploy-ramdisk}
ipmi_username=${IRONIC_IPMI_USERNAME:-admin}
ipmi_password=${IRONIC_IPMI_PASSWORD:-password}
ipmi_port=${IRONIC_IPMI_PORT:-623}
resource_class=${IRONIC_RESOURCE_CLASS:-baremetal}

usage() {
	echo "${0##*/}: usage: ${0##*/} [--kernel <kernal_image_uuid>] [--ramdisk <ramdisk_image_uuid] [--ipmi-host <host>] [--ipmi-port <port>] [--ipmi-user <user>] [--ipmi-password <password>] [--resource-class <class>] name mac_addr"
}

OPTS=$(getopt -o 'k:r:H:U:P:p:R:' --long 'resource-class:,ipmi-username:,ipmi-password:,ipmi-host:,ipmi-port:,ramdisk:,kernel:,help' -n "${0##*/}" -- "$@")
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
		(-H|--ipmi-host)
			ipmi_host=$2
			shift 2
			;;
		(-p|--ipmi-port)
			ipmi_port=$2
			shift 2
			;;
		(-U|--ipmi-user)
			ipmi_user=$2
			shift 2
			;;
		(-P|--ipmi-password)
			ipmi_password=$2
			shift 2
			;;
		(-R|--resource-class)
			resource_class=$2
			shift 2
			;;

		(--help)
			usage
			exit 0
			;;

		(--)	shift
			break
			;;
	esac
done

if [ $# -ne 2 ]; then
	usage >&2
	exit 2
fi

node_name=$1
node_macaddr=$2

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

openstack baremetal node create --name "$node_name" \
	--driver ipmi \
	--driver-info ipmi_address=$ipmi_host \
	--driver-info ipmi_port=$ipmi_port \
	--driver-info ipmi_username=$ipmi_username \
	--driver-info ipmi_password=$ipmi_password \
	--driver-info deploy_kernel=$kernel_uuid \
	--driver-info deploy_ramdisk=$ramdisk_uuid \
	--driver-info provisioning_network=provisioning \
	--driver-info cleaning_network=provisioning \
	--property capabilities=iscsi_boot:True \
	--resource-class $resource_class

node_uuid=$(openstack baremetal node show $node_name -f value -c uuid)
if [[ $? -ne 0 ]]; then
	echo "ERROR: unable to look up uuid for node $node_name" >&2
	exit 1
fi

openstack baremetal port create $node_macaddr --node $node_uuid
openstack baremetal node set --storage-interface cinder $node_uuid
openstack baremetal volume connector create \
          --node $node_uuid \
	  --type iqn \
	  --connector-id iqn.2017-08.org.openstack.$node_uuid
