#!/bin/sh

NETWORK=192.168.1
IP=$NETWORK.2
NETMASK=24
INTERFACE=em2

# Use default template location unless TEMPLATES is set in the environment
# before running deploy.sh.
: ${TEMPLATES:=/usr/share/openstack-tripleo-heat-templates}

## Create backup of modified packaged files and copy new versions

mkdir -p backup

# disable ftype check

if [ ! -f backup/container-registry_tasks_docker.yml ]; then
	cp /usr/share/ansible/roles/container-registry/tasks/docker.yml \
		backup/container-registry_tasks_docker.yml
fi

sudo cp files/docker.yml.noftypecheck \
	/usr/share/ansible/roles/container-registry/tasks/docker.yml

## Deploy

openstack tripleo container image prepare default \
  --output-env-file ./containers-prepare-parameters.yaml

mkdir -p deploy

deploy_args=(
  -e $TEMPLATES/environments/standalone/standalone-tripleo.yaml
  -r $TEMPLATES/roles/Standalone.yaml
  -e $TEMPLATES/environments/services/ironic.yaml
  -e $TEMPLATES/environments/services/ironic-inspector.yaml

  # Enable external ceph
  -e $TEMPLATES/environments/ceph-ansible/ceph-ansible-external.yaml
  -e ./ceph-pool-names.yaml
  -e ./ceph-credentials.yaml

  # Local settings
  -e ./containers-prepare-parameters.yaml
  -e ./standalone_parameters.yaml
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
