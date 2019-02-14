#!/bin/sh

BASEIMAGE=CentOS-7-x86_64-GenericCloud.qcow2

if [ ! -f ${BASEIMAGE}.xz ]; then
	echo "fetching image"
	curl -O https://cloud.centos.org/centos/7/images/${BASEIMAGE}.xz
fi

echo "extracting working image"
xz -d < ${BASEIMAGE}.xz > ${BASEIMAGE}
LIBGUESTFS_BACKEND=direct virt-customize -a ${BASEIMAGE} \
	--run configure-image.sh \
	--selinux-relabel
