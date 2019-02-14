#!/bin/sh

NETWORK=192.168.1
IP=$NETWORK.2
NETMASK=24
INTERFACE=em2

# Use default template location unless TEMPLATES is set in the environment
# before running deploy.sh.
: ${TEMPLATES:=/usr/share/openstack-tripleo-heat-templates}

## sanity checks

if ! rpm --quiet -q ceph-ansible; then
	echo "***ERROR*** Cannot continue without ceph-ansible package" >&2
	exit 1
fi

## Create backup of modified packaged files and copy new versions

mkdir -p backup

# disable ftype check

if [ ! -f backup/container-registry_tasks_docker.yml ]; then
	cp /usr/share/ansible/roles/container-registry/tasks/docker.yml \
		backup/container-registry_tasks_docker.yml
fi

sudo cp files/docker.yml.noftypecheck \
	/usr/share/ansible/roles/container-registry/tasks/docker.yml

sudo cp files/lvmlocal.conf /etc/lvm/lvmlocal.conf

## Deploy

openstack tripleo container image prepare default \
  --output-env-file ./containers-prepare-parameters.yaml

mkdir -p deploy
mkdir -p /tmp/ceph_ansible_fetch

deploy_args=(
  -e $TEMPLATES/environments/standalone/standalone-tripleo.yaml
  -r $TEMPLATES/roles/Standalone.yaml
  -e $TEMPLATES/environments/services/ironic.yaml
  -e $TEMPLATES/environments/services/ironic-inspector.yaml

  # Enable external ceph
  -e $TEMPLATES/environments/ceph-ansible/ceph-ansible-external.yaml
  -e ./ceph-local-config.yaml
  -e ./ceph-credentials.yaml

  # Local settings
  -e ./containers-prepare-parameters.yaml
  -e ./standalone_parameters.yaml
  -e ./image-config.yaml
)

if [ -f ./local.yaml ]; then
  deploy_args+=(-e ./local.yaml)
fi

sudo openstack tripleo deploy \
  --templates $TEMPLATES \
  --local-ip=$IP/$NETMASK \
  --output-dir deploy \
  --standalone \
  "${deploy_args[@]}" \
  "$@"
