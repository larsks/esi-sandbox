#!/bin/bash

{% include "deploy_args.j2.sh" %}

set -x
openstack tripleo container image prepare \
	"${deploy_args[@]}" \
	-e container-prepare-parameters.yaml \
	--output-env container-images.yaml
