NVM=openstack-vm-test
STATIC_IP='10.10.17.245'
a=`ansible openstack -m shell -a "vim-cmd vmsvc/getallvms" | grep -o "$NVM"`
if test "$a" != "$NVM"
then
	ansible-playbook copy_script.yml  
	a=`ansible openstack -m shell -a "vim-cmd vmsvc/getallvms" | grep "$NVM" | cut -d " " -f 1` 
	ansible openstack -m shell -a "vim-cmd vmsvc/power.on $a"
	brave-browser --url http://10.10.20.222/ui/#/console/$a --incognito
else
	echo problem locating vm vmdk file ...
	exit 1 
fi

unset NVM
b=`ansible openstack -m shell -a "vim-cmd vmsvc/power.getstate $a"`
if test "$b" == "Powered on"
then
	echo "OpenStack VM is powerd on ..."
fi
echo waiting for OS installation ...
sleep 1000
VM_IP="$STATIC_IP"
SSH_PORT="22"
SSH_USER="stack"
SSH_KEY="/home/dinho/.ssh/id_rsa"
unset STATIC_IP
    countdown() {
    secs=$1
    while [ $secs -gt 0 ]; do
        echo -ne "Remaining time: $secs seconds \r"
        sleep 1
        : $((secs--))
    done
}
a=0
echo "Initial value of startup cycles: $a"
while [ "$a" != '2' ]
do
    echo "waiting for reboot ..."
    countdown 10
    a=$(ansible openstack -m shell -a "cat /vmfs/volumes/datastore1/openstack-vm-test/vmware.log | grep 'Reporting power state change' | grep 'vmx|' | wc -l" | grep -o 2)
done
while ! nc -zv $VM_IP $SSH_PORT
do
    	echo "Waiting for VM to be available..."
    	sleep 10
done
echo "VM is available ..."
unset SSH_PORT
unset SSH_USER
unset SSH_KEY
unset VM_IP
