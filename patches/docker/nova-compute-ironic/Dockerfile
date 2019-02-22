FROM docker.io/tripleomaster/centos-binary-nova-compute-ironic:current-tripleo

ARG project=nova
ARG git_repo_url=https://git.openstack.org/openstack/nova
ARG git_refspec=refs/changes/99/636699/4

USER root
WORKDIR /tmp

RUN yum -y install git                           && \
	git clone ${git_repo_url} patch          && \
	cd patch                                 && \
	git fetch ${git_repo_url} ${git_refspec} && \
	git checkout FETCH_HEAD                  && \
	python setup.py install                  && \
	cd ..                                    && \
	rm -rf patch                             && \
	yum clean all
	
WORKDIR /
USER nova
