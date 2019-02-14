#!/bin/sh

BASEIMAGE=bionic-server-cloudimg-amd64.img

set -e

if [ ! -f ${BASEIMAGE}.orig ]; then
	echo "fetching image"
	curl -o ${BASEIMAGE}.orig https://cloud-images.ubuntu.com/bionic/current/${BASEIMAGE}
fi

echo "creating working image"
cp ${BASEIMAGE}.orig ${BASEIMAGE}
LIBGUESTFS_BACKEND=direct virt-customize -a ${BASEIMAGE} \
	--run configure-image.sh
