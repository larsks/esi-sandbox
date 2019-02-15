#!/bin/sh

apt-get -y update
apt-get -y dist-upgrade
apt-get -y install open-iscsi
apt-get clean

echo "ISCSI_AUTO=true" > /etc/iscsi/iscsi.initramfs
update-initramfs -u

sed -i '/GRUB_CMDLINE_LINUX/ s/"$/ rd.iscsi.firmware=1 ci.ds=OpenStack"/' \
	/etc/default/grub

update-grub

# Fix a bug in cloud-init that prevents it from running on a baremetal server
# https://bugs.launchpad.net/cloud-init/+bug/1815990
sed -i '/^ *def detect_openstack/ a\
    return True
' /usr/lib/python3/dist-packages/cloudinit/sources/DataSourceOpenStack.py
