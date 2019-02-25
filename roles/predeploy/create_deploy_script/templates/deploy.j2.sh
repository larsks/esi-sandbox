#!/bin/bash

deploy_args=(
{% for arg in deploy_args %}
  {{ arg }}
{% endfor %}
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
