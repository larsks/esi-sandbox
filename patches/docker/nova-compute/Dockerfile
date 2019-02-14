FROM docker.io/tripleomaster/centos-binary-nova-compute:current-tripleo

USER root
WORKDIR /tmp

RUN yum -y install git; \
	git clone https://git.openstack.org/openstack/nova; \
	cd nova; \
	git fetch https://git.openstack.org/openstack/nova refs/changes/99/636699/2 && git checkout FETCH_HEAD; \
	python setup.py install; \
	yum clean all
	

WORKDIR /
USER nova
