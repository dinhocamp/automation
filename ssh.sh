#!/bin/bash

ssh_username="stack"
openstack_vm="openstack"
remote_host="openstack-vm-test"

ssh-keygen -f "/home/dinho/.ssh/known_hosts" -R "$remote_host"
if test $? == 0
then
	echo success removing old known hosts
else
	echo failed removing old known hosts
fi
ping -c 1 "$remote_host" > /dev/null && echo "Ping successful" || echo "Ping failed"

sshpass -p "$openstack_vm" ssh-copy-id -i /home/dinho/.ssh/id_rsa.pub -o StrictHostKeyChecking=no "$ssh_username@$remote_host"
if test $? == 0
then
	echo success ssh keys 
else
	echo failed ssh keys
fi
ansible-playbook ssh_config.yml

