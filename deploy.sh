#!/bin/bash
if test "$SUDO_USER" == "dinho" #Replace "dinho" with root user 
then
	echo configuring esxi ...
	bash ESXI_ssh_config.sh
	if test $? -eq 0
	then
		echo ESXI is configured successfully
	else
		echo problem configuring ESXI
		cat ./error.txt
	fi
else
	echo -e "your are not root\nexecute the script with sudo privileges"
	exit 1
fi
#ansible-playbook -i inventory devstack_installation.yml
