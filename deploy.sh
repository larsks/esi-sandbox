# Create backup of modified packaged files and copy new versions
sudo cp standalone-tripleo.yaml.ironic /usr/share/openstack-tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml /usr/share/openstack-tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml.orig
sudo cp standalone-tripleo.yaml.ironic /usr/share/openstack-tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml

sudo cp /usr/share/ansible/roles/container-registry/tasks/docker.yml /usr/share/ansible/roles/container-registry/tasks/docker.yml.orig
sudo cp docker.yml.noftypecheck /usr/share/ansible/roles/container-registry/tasks/docker.yml

export NETWORK=192.168.1
export IP=$NETWORK.2
export NETMASK=24
export INTERFACE=em2

openstack tripleo container image prepare default \
  --output-env-file `pwd`/containers-prepare-parameters.yaml

sudo openstack tripleo deploy \
  --templates \
  --local-ip=$IP/$NETMASK \
  -e /usr/share/openstack-tripleo-heat-templates/environments/standalone/standalone-tripleo.yaml \
  -r /usr/share/openstack-tripleo-heat-templates/roles/Standalone.yaml \
  -e `pwd`/containers-prepare-parameters.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/services/ironic.yaml \
  -e /usr/share/openstack-tripleo-heat-templates/environments/services/ironic-inspector.yaml \
  -r /usr/share/openstack-tripleo-heat-templates/roles/Standalone.yaml \
  -e `pwd`/standalone_parameters.yaml \
  --output-dir `pwd` \
  --standalone
