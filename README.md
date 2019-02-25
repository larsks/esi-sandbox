# Requirements

Deployment based on <https://docs.openstack.org/tripleo-docs/latest/install/containers_deployment/standalone.html>.

## Prepare your target host

### Filesystem configuration

You will need a system running CentOS 7 with sufficient disk space. The deploy will consume space from:

- `/var/lib/docker`: docker images and containers
- `/var/lib/config-data`: generated configuration information
- `/var/lib/ironic`: used for staging disk images before deploying them to hosts in boot-from-image mode.
- `/var/lib/mysql`: mysql databases used by openstack services
- `/srv`: local storage for swift (including glance images)

If you have a large `/` filesystem you will be fine. Alternately, you could mount additional space on `/var/lib` and on `/srv`.

### Configure ssh access

Ensure that you can `ssh` into the `root` account on your server using ssh key authentication.

## Prepare an Ansible inventory

Create an ansible inventory file in `hosts.yml` with your target system in the `controller` group.  Assuming that the target system was at `192.168.122.54` , your inventory would look like:

    ---
    all:
     children:
       controller:
         hosts:
           192.168.122.54:
             ansible_user: stack

### Run the host playbook

Run the host playbook:

    ansible-playbook playbook-host.yml

This will:

- create a `stack` user on the target host with `sudo` privileges
- install public keys from a local file named `authorized_keys`
- install tripleo repositories
- install python-tripleoclient and dependencies

## Run the predeploy playbook

Run the predeploy playbook:

    ansible-playbook playbook-pre.yml

If you are overriding anything in the default configuration, you can include the overrides on the command line. For example, if you had settings in `config.yml`:

    ansible-playbook playbook-pre.yml -e @config.yml

This playbook will:

- generate configuration files necessary for deployment
- generate scripts to run the deployment

## Run the deploy scripts

Log into the target host and run the generated deploy script:

        stack$ ./deploy.sh

## Run the post-deploy playbook

Run the predeploy playbook:

    ansible-playbook playbook-pre.yml

This will:

- set up the required neutron networks
- upload deploy kernel and ramdisk images to glance
- create a `baremetal` nova flavor
- install some helper scripts into the `stack` user `bin/` directory.
