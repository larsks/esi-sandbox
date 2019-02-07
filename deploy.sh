## Create backup of modified packaged files and copy new versions

# disable NovaCompute
sudo cp files/standalone-tripleo.yaml.ironic /usr/share/openstack-tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml

# disable ftype check
sudo cp /usr/share/ansible/roles/container-registry/tasks/docker.yml /usr/share/ansible/roles/container-registry/tasks/docker.yml.orig
sudo cp files/docker.yml.noftypecheck /usr/share/ansible/roles/container-registry/tasks/docker.yml

## Deploy

export NETWORK=192.168.1
export IP=$NETWORK.2
export NETMASK=24
export INTERFACE=em2

openstack tripleo container image prepare default \
  --output-env-file ./containers-prepare-parameters.yaml

sudo openstack tripleo deploy \
  --templates \
  --local-ip=$IP/$NETMASK \
  -e /usr/share/openstack-tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml \
  -r /usr/share/openstack-tripleo-heat-templates/roles/Standalone.yaml \
  -e ./containers-prepare-parameters.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/services/ironic.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/services/ironic-inspector.yaml \
  -r /usr/share/openstack-tripleo-heat-templates/roles/Standalone.yaml \
  -e ./standalone_parameters.yaml \
  --output-dir . \
  --standalone \
  "$@"
