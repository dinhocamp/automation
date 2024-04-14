#!/bin/bash
SEGMENT_2=$(openssl rand -hex 1)
SEGMENT_3=$(openssl rand -hex 1)
SEGMENT_4=$(openssl rand -hex 1)

MAC_ADDRESS="DE:AD:BE:$SEGMENT_2:$SEGMENT_3:$SEGMENT_4"
unset SEGMENT_2
unset SEGMENT_3
unset SEGMENT_4
MAC_ADDRESS=$(echo "$MAC_ADDRESS" | tr '[:lower:]' '[:upper:]')
echo "Generated MAC address: $MAC_ADDRESS"
echo assign A name for he VM
read NVM      
NVMDIR="$NVM"
echo assign A hard disk size for the "$NVM" machine\nexample :60 if you want a 60 g hard disk size 
read NVMSIZE 
echo the hard disk size chosen is $NVMSIZE            
echo assign A RAM size for the "$NVM" machine\nexample :1024 if you want a 1 g RAM size 
read VMMEMSIZE
echo the RAM size chosen is $VMMEMSIZE 
echo assign An IP ADDRESS for the "$NVM" machine\nexample :10.10.17.245 if you want 10.10.17.245 as an address 
read STATIC_IP
echo the STATIC_IP chosen is $STATIC_IP
echo assign A NETMASK for the "$NVM" machine\nexample :255.255.255.0 if you want 255.255.255.0 as a netmask 
read NETMASK 
echo the NETMASK chosen is $NETMASK      
#echo assign ipv4 address to the opensatck machine
adr="$STATIC_IP/24"
#echo the address chosen is $address
echo assign ipv4 gateway to the opensatck machine
read gateway
echo the gateway chosen is $gateway
sed -i "s|^MAC_ADDRESS=.*|MAC_ADDRESS=\""$MAC_ADDRESS"\"|g" /home/dinho/automation/create_vm.sh
sed -i "s|^NVM=.*|NVM=\""$NVM"\"|g" /home/dinho/automation/create_vm.sh
sed -i "s|^NVMSIZE=.*|NVMSIZE=\""$NVMSIZE"g\"|g" /home/dinho/automation/create_vm.sh
sed -i "s|^VMMEMSIZE=.*|VMMEMSIZE=\""$VMMEMSIZE"\"|g" /home/dinho/automation/create_vm.sh
sed -i "s|^STATIC_IP=.*|STATIC_IP=\""$STATIC_IP"\"|g" /home/dinho/automation/create_vm.sh
sed -i "s|^NETMASK=.*|NETMASK=\""$NETMASK"\"|g" /home/dinho/automation/create_vm.sh
ESXI_pass='root*2023'
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
				echo -e "your are not root from esxi_ssh_file\nexecute the script with sudo privileges"
			fi
		else
			echo sshpass is installed
		fi
check=`find /home/dinho/.ssh -type f -name "id_rsa.pub" | grep -o "id_rsa.pub"`
if test "$check" != "id_rsa.pub"
then
		ssh-keygen -t rsa -N "" -f /home/dinho/.ssh/id_rsa
		ssh-keygen -f "/home/dinho/.ssh/known_hosts" -R "openstack"
		chown -R dinho:dinho /home/dinho/.ssh
		chmod 700 /home/dinho/.ssh
		chmod 600 /home/dinho/.ssh/*
		key=`cat /home/dinho/.ssh/id_rsa.pub | cut -d ' ' -f 2`
		#sshpass -p "$ESXI_pass" ssh-copy-id -i /home/dinho/.ssh/id_rsa.pub -o StrictHostKeyChecking=no root@openstack
fi
if test "$SUDO_USER" == "dinho" #Replace "dinho" with root user 
then
	echo preparing custom iso file for ubuntu-server
	cat /home/dinho/automation/custom_iso_installers/custom_iso/user-data_default > /home/dinho/automation/custom_iso_installers/custom_iso/user-data
	sed -i "s|ssh_key|\"ssh-rsa "$key"\"|g" /home/dinho/automation/custom_iso_installers/custom_iso/user-data
	sed -i "s|adr|$adr|g" /home/dinho/automation/custom_iso_installers/custom_iso/user-data
	sed -i "s|gtw|$gateway|g" /home/dinho/automation/custom_iso_installers/custom_iso/user-data
	sed -i "s|machine_name|$NVM|g" /home/dinho/automation/custom_iso_installers/custom_iso/user-data  
	bash prepare_iso_files.sh
	sshpass -p "$ESXI_pass" scp -o StrictHostKeyChecking=no /home/dinho/install_server.iso root@openstack:/vmfs/volumes/datastore1/install_server.iso
	if test $? -eq 0
	then
		echo iso file copyied
	else
		echo problem copying iso file on target
		cat ./error.txt
	fi
else
	echo -e "your are not root \nexecute the script with sudo privileges"
	exit 1
fi
unset adr
unset key
unset gateway
unset NVMDIR
unset NVMSIZE
unset VMMEMSIZE
unset NETMASK
unset ESXI_pass
a=`ansible-playbook ssh_key_verification.yml | grep -o true`
if test "$a" == 'true'
then
	echo problem ssh key dispatching
	#sshpass -p "$ESXI_pass" ssh-copy-id -i /home/dinho/.ssh/id_rsa.pub root@openstack
fi
a=`ansible openstack -m shell -a "vim-cmd vmsvc/getallvms" | grep -o "$NVM"`
if test "$a" != "$NVM"
then
	ansible-playbook copy_script.yml  
	a=`ansible openstack -m shell -a "vim-cmd vmsvc/getallvms" | grep "$NVM" | cut -d " " -f 1` 
	ansible openstack -m shell -a "vim-cmd vmsvc/power.on $a"
fi
unset NVM
b=`ansible openstack -m shell -a "vim-cmd vmsvc/power.getstate $a"`
if test "$b" == "Powered on"
then
	echo "OpenStack VM is powerd on ..."
fi
#sshpass -p "$ESXI_pass" ssh-copy-id -i /home/dinho/.ssh/id_rsa.pub root@openstack
echo waiting for OS installation ...
sleep 600
VM_IP="$STATIC_IP"
SSH_PORT="22"
SSH_USER="cloud-admin"
SSH_KEY="/home/dinho/.ssh/id_rsa"
unset STATIC_IP


while ! nc -zv $VM_IP $SSH_PORT
do
    echo "Waiting for VM to be available..."
    sleep 10
done
echo "VM is available. Attempting SSH connection..."
ssh -i $SSH_KEY $SSH_USER@$VM_IP
unset SSH_PORT
unset SSH_USER
unset SSH_KEY
unset VM_IP
