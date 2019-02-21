#!/usr/bin/env python

from __future__ import print_function

import docker.client
import click
import psutil
import subprocess


def get_all_containers():
    '''Look up the main pid of all docker containers and return a
    pid: container map'''

    try:
        client = docker.client.APIClient()
    except AttributeError:
        client = docker.client.Client()

    container_pids = {}
    for container in client.containers():
        container_data = client.inspect_container(container)
        container_pids[container_data['State']['Pid']] = container

    return container_pids


@click.command()
@click.option('-t', '--tree', is_flag=True)
@click.argument('pid', type=int)
def get_container_from_pid(tree, pid):
    container_pids = get_all_containers()
    proc = psutil.Process(pid)
    while proc.pid not in container_pids and proc.pid != 1:
        proc = proc.parent()

    if proc.pid != 1:
        container = container_pids[proc.pid]
        print('{pid} {name} {cid}'.format(
            pid=proc.pid,
            name=container['Names'][0][1:],
            cid=container['Id']))
        if (tree):
            print()
            subprocess.call(('pstree',
                             '-p', '{}'.format(proc.pid),
                             '-H', '{}'.format(pid)))


if __name__ == '__main__':
    get_container_from_pid()
