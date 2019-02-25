#!/bin/bash

{% include "deploy_args.j2.sh" %}

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
