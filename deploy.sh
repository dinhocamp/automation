#!/bin/bash
CURRENT_USER=$USER
echo the current user is $CURRENT_USER
for file in *; do
    if [ -f "$file" ]; then
        sed -i "s/dinho/$CURRENT_USER/g" "$file"
        echo "Replaced occurrences of dinho with $CURRENT_USER in $file"
    fi
done
unset file
sudo bash ansible_installation.sh
	echo configuring esxi ...
	sudo bash ESXI_ssh_config.sh
	if test $? -eq 0
	then
		echo ESXI is configured successfully
		bash esxi_verif.sh
		b=`ansible-playbook ssh_key_verification.yml | grep -o true`
		echo the value of b=" $b"
		if test "$b" == 'true'
		then
				echo problem ssh key dispatching
				bash ssh.sh
				ansible-playbook ssh_config.yml --vault-password-file /home/dinho/.vault_passwd
		fi
		ansible-playbook ssh_key_verification.yml
	else
		echo problem configuring ESXI
		cat ./error.txt
	fi
#fi
unset b
res=`ssh -o "StrictHostKeyChecking=no" stack@openstack-vm-test "git --version" &>/dev/null | grep -o '\d+\.\d+\.\d+'`

if test "$res" == "" 
then
	ssh -o "StrictHostKeyChecking=no" stack@openstack-vm-test "sudo apt-get install git"
fi
ADMIN_PASSWORD=secret
ansible-playbook -v -i inventory devstack_installation.yml
unset res
a=`cat /etc/hosts | grep openstack$ | cut -d " " -f 1`
brave-browser --url "http://$a" --incognito
echo do you want to continuing the envirement setup ?
read a 
while [ "$a" != 'y' ] && [ "$a" != 'n' ]
do
	echo please press y to continue the setup or n to quit
	read a
done
if test $a == 'y'
then
	ansible-playbook scp_Vars.yml
else
	exit 1
fi
unset a
