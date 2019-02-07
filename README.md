# Requirements

Deployment based on https://docs.openstack.org/tripleo-docs/latest/install/containers_deployment/standalone.html

```
sudo yum install -y https://trunk.rdoproject.org/centos7/current/python2-tripleo-repos-0.0.1-0.20181218212820.a5b709e.el7.noarch.rpm
sudo -E tripleo-repos current-tripleo-dev
sudo yum install -y python-tripleoclient

./deploy.sh
```
