#!/bin/bash
check_ans=`ansible --version &>./tmp.txt; cat tmp.txt | grep 'not found' | wc -l`
rm ./tmp.txt
if test $check_ans -eq 1 
then
	echo ansible not installed yet
	if test "$SUDO_USER" == "dinho" #Replace "dinho" with root user 
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
		pass=`dpkg -l | grep -o sshpass | wc -l`
		if test $pass -eq 0
		then
			if test "$SUDO_USER" == "dinho" #Replace "dinho" with root user 
			then
				echo installing sshpass
				apt-get install sshpass 2> error.txt
				if test $? -eq 0
				then
					echo sshpass is installed successfully
				else
					echo problem installing sshpass
					cat ./error.txt
				fi
			else
				echo -e "your are not root\nexecute the script with sudo privileges"
				exit 1
			fi
		else
			echo sshpass is installed
		fi
		#check_ans=`dpkg -l | grep openstack | wc -l`
		#if test $check_ans -eq 0 
		#then
			check=`find /home/dinho/.ssh -type f -name "id_rsa.pub" | grep -o "id_rsa.pub"`
			echo "echoing to troubleshoot check variable is $check"
			if test "$check" != "id_rsa.pub"
			then
			ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
			sshpass -p 'root*2023' ssh-copy-id -i /home/dinho/.ssh/id_rsa.pub root@openstack
			else
			ansible-playbook copy_script.yml  
			a=`ansible openstack -m shell -a "vim-cmd vmsvc/getallvms" | grep openstack | cut -d " " -f 1`
			sleep 10 
			ansible openstack -m shell -a "vim-cmd vmsvc/power.on $a"
			#vim-cmd vmsvc/getallvms | grep "openstack"
			res=`ssh -o "StrictHostKeyChecking=no" root@openstack "git --version" &>/dev/null | grep -o '\d+\.\d+\.\d+'`	
			#check if git is installed on the remote machine
			if test "$res" == "" 
			then
			ssh -o "StrictHostKeyChecking=no" root@openstack "sudo apt-get install git"
			fi
			ansible-playbook -i inventory ssh_config.yml			
			ansible-playbook -i inventory devstack_installation.yml
			ansible-playbook -i inventory check_openstack_installation.yml
			fi
			unset check_ans
			unset check
			#Replace root@openstack with the the remote user@ip_address 
			#check for sshpass is already installed on localhost
		#else
			#echo openstack is installed
		#fi
elif [ $a == 'n' ]
then
	echo aborting ...
fi
