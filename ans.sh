#!/bin/bash
check_ans=`ansible --version &>./tmp.txt; cat tmp.txt | grep 'not found' | wc -l`
rm ./tmp.txt
if test $check_ans -eq 1 
then
	echo ansible not installed yet
	if test "$SUDO_USER" == "dinho" 
	then
		echo installing ansible
		apt-get install ansible 2> error.txt
		if test $? -eq 0
		then
			echo ansible is installed successfully
			ansible --version
		else
			echo problem downloading ansible
			cat ./error.txt
		fi
	else
		echo -e "your are not root\nexecute the script with sudo privileges"
		exit 1
	fi
else
	echo ansible is installed
	version=`ansible --version`
	echo $version
fi 
unset check_ans
echo -e "do you want to install openstack ?\nenter y to continue or n to quit"
read a
while test $a != 'y' -a $a != 'n' 
do
	echo -e "enter y to install openstack or enter n to abort ..."
	read a
done
if [ $a == 'y' ]
then
	echo "checking if openstack already installed ..."
	#if test "$SUDO_USER" == 'dinho'
	#then
		check_ans=`dpkg -l | grep openstack | wc -l`
		if test $check_ans -eq 0 
		then
			unset check_ans
			res=`ssh -o "StrictHostKeyChecking=no" cloud-admin@openstack "git --version" &>/dev/null | grep -o '\d+\.\d+\.\d+'`	
			echo "result is "
			if test "$res" == "" 
			then
			ssh -o "StrictHostKeyChecking=no" cloud-admin@openstack "sudo apt-get install git"
			fi
			check_ans=`find /home/dinho/.ssh -type f -name "id_rsa.pub" | grep -o 'No such file'`
			if test "$check_ans" == "No such file"
			then
			ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
			ssh-copy-id -i /home/dinho/.ssh/id_rsa.pub cloud-admin@openstack		
			else
			ansible-playbook -i inventory ssh_config.yml
			ansible-playbook -i inventory create_stack_user.yml			
			ansible-playbook -i inventory devstack_installation.yml
			fi
			#check for sshpass is already installed
			#check if git is installed on the remote machine
		else
			echo openstack is installed
		fi
	#else
		#echo this script needs root privileges
	#fi
elif [ $a == 'n' ]
then
	echo aborting ...
fi
