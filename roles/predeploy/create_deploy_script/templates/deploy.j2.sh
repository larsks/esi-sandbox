#!/bin/bash

{% if 'ovn' in neutron_mechanism_drivers -%}
{% set network_deploy_args = ovn_deploy_args -%}
{% elif 'openvswitch' in neutron_mechanism_drivers -%}
{% set network_deploy_args = ovs_deploy_args -%}
{% else -%}
{% set network_deploy_args = [] -%}
{% endif -%}

deploy_args=(
{% for arg in deploy_args + network_deploy_args %}
  {{ arg }}
{% endfor %}

  # parameters generated by create_config role
  -e ./standalone_parameters.yaml

{% for arg in deploy_args_extra|default([]) %}
  {{ arg }}
{% endfor %}
)

if [ -f ./local.yaml ]; then
  deploy_args+=(-e ./local.yaml)
fi

set -x
openstack tripleo container image prepare \
	"${deploy_args[@]}" \
	-e container-prepare-parameters.yaml \
	--output-env container-images.yaml

sudo openstack tripleo deploy \
  --templates $TEMPLATES \
  --local-ip={{ standalone_ip }}/{{ standalone_subnet|ipaddr('prefix') }} \
  --output-dir deploy \
  --standalone \
  -e ./container-images.yaml \
  "${deploy_args[@]}" \
  "$@"
