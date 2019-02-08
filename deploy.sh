#!/bin/sh

export NETWORK=192.168.1
export IP=$NETWORK.2
export NETMASK=24
export INTERFACE=em2

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

sudo openstack tripleo deploy \
  --templates $TEMPLATES \
  --local-ip=$IP/$NETMASK \
  -e /usr/share/openstack-tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml \
  -r /usr/share/openstack-tripleo-heat-templates/roles/Standalone.yaml \
  -e ./containers-prepare-parameters.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/services/ironic.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/services/ironic-inspector.yaml \
  -r /usr/share/openstack-tripleo-heat-templates/roles/Standalone.yaml \
  -e ./standalone_parameters.yaml \
  --output-dir deploy \
  --standalone \
  "$@"
