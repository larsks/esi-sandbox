#!/bin/sh

CIDR=$NETWORK.1/24

# Use default template location unless TEMPLATES is set in the environment
# before running deploy.sh.
: ${TEMPLATES:=/usr/share/openstack-tripleo-heat-templates}

## Deploy

openstack tripleo container image prepare default \
  --output-env-file ./containers-prepare-parameters.yaml

mkdir -p deploy
mkdir -p /tmp/ceph_ansible_fetch

ansible-playbooks playbook.yml -t deploy

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
)

if [ -f ./local.yaml ]; then
  deploy_args+=(-e ./local.yaml)
fi

sudo openstack tripleo deploy \
  --templates $TEMPLATES \
  --local-ip=$CIDR \
  --output-dir deploy \
  --standalone \
  "${deploy_args[@]}" \
  "$@"
