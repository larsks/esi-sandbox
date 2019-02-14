#!/bin/sh

apt-get -y update
apt-get -y dist-upgrade
apt-get -y install open-iscsi
apt-get clean

echo "ISCSI_AUTO=true" > /etc/iscsi/iscsi.initramfs
update-initramfs -u

sed -i '/GRUB_CMDLINE_LINUX/ s/"$/ rd.iscsi.firmware=1"/' \
	/etc/default/grub

update-grub
