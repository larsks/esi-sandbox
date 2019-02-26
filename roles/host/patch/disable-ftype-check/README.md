If /var/lib/docker is on an XFS filesystem, it must be formatted with ftype=1. This has been the default since RHEL 7.3. The check for this in tripleo is too broad and will cause the deploy to fail if / has ftype=0, even if /var/lib/docker is on a filesystem with ftype=1.  

This patch changes the `fail:` task in `/usr/share/ansible/roles/container-registry/tasks/docker.yml` to a warning message.
