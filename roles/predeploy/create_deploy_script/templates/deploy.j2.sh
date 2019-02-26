#!/bin/bash

{% include "deploy_args.j2.sh" %}

if ! mkdir /tmp/.deploy.lock; then
        echo "***ERROR*** It looks like a deploy is already running" >&2
        exit 1
fi

trap "rmdir /tmp/.deploy.lock" EXIT

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
