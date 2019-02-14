#!/bin/sh

BASEIMAGE=CentOS-7-x86_64-GenericCloud.qcow2
NBD=/dev/nbd0
MNT=/mnt

if ! modprobe nbd; then
	echo "cannot continue without nbd module" >&2
	exit 1
fi

if [ ! -f ${BASEIMAGE}.xz ]; then
	echo "fetching image"
	curl -O https://cloud.centos.org/centos/7/images/${BASEIMAGE}.xz
fi

echo "extracting working image"
xz -d < ${BASEIMAGE}.xz > ${BASEIMAGE}

(
	set -e

	echo "mounting image"
	qemu-nbd -c ${NBD} -f qcow2 ${BASEIMAGE}
	sleep 1
	mount ${NBD}p1 ${MNT}

	echo "configuring image"
	systemd-nspawn -D ${MNT} <<-'EOF'
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

		grub2-set-default 0
	EOF

	umount ${MNT}

	echo "finishing up"
	LIBGUESTFS_BACKEND=direct virt-customize -a ${NBD}p1 \
		--run-command "grub2-mkconfig -o /boot/grub2/grub.cfg" \
		--selinux-relabel
)

umount ${MNT}
qemu-nbd -d ${NBD}
