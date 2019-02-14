#!/bin/sh

yum -y upgrade
yum install -y iscsi-initiator-utils
yum clean all

kversion=$(rpm -q --qf="%{BUILDTIME} %{VERSION}-%{RELEASE}.%{ARCH}\n" \
	kernel |
	sort -k1 -n | tail -1 | cut -f2 -d' ')

dracut --force --add "network iscsi" \
	/boot/initramfs-${kversion}.img \
	${kversion}

sed -i '/GRUB_CMDLINE_LINUX/ s/"$/ rd.iscsi.firmware=1"/' \
	/etc/default/grub

grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
