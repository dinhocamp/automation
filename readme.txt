create a VM (ansible engine machine) to manage the openstack host (ansible client machine)
configure /etc/hosts with openstack as alias for the openstack host machine and give it the IP address (include ping test later on the script ans.sh)
configure the cloud-admin user with "openstack" as password
configure the openstack host to allow ssh public key authentication or create a stack user for more scope for the management machine to manage the openstack cloud.
create a VM to host OpenStack
install openssh-server on the openstack host
edit /etc/ssh/ssh_config for PasswordAuthentication yes
collect the user of the VM and it's creadentials to use on ansible host machine for ssh connection
use ssh_config playbook to configure a passwordless connection for further playbooks and security (public test key ssh)
auth configuration 


# This script will create a VM with the following attributes;
# Virtual Machine Name = ScriptedVM
# Location of Virtual Machine = /VMFS/volumes/datastore1/ScriptedVM
#----------------------------------------+
#Custom Variable Section for Modification|
#----------------------------------------+---------------------
#NVM is name of virtual machine(NVM). No Spaces allowed in name
#NVMDIR is the directory which holds all the VM files
#NVMOS specifies VM Operating System
#NVMSIZE is the size of the virtual disk to be created
#--------------------------------------------------------------
###############################################################
### Default Variable settings - change this to your preferences
NVM="ScriptedVM" # Name of Virtual Machine
NVMDIR="ScriptedVM" # Specify only the folder name to be created; NOT the
complete path
NVMOS="ubuntu-64" # Type of OS for Virtual Machine
NVMSIZE="4g" # Size of Virtual Machine Disk
VMMEMSIZE="256" # Default Memory Size
### End Variable Declaration
mkdir /vmfs/volumes/storage1/$NVMDIR # Creates directory
exec 6>&1 # Sets up write to file
exec 1>/vmfs/volumes/storage1/$NVMDIR/$NVM.vmx # Open file
# write the configuration
echo config.version = '"'6'"' # For ESX 3.x the value is 8
echo virtualHW.version = '"'3'"' # For ESX 3.x the value is 4
echo memsize = '"'$VMMEMSIZE'"'
www.syngress.com
Building a VM • Chapter 4 151
370_VMware_Tools_04_dummy.qxd 10/12/06 7:28 PM Page 151
echo floppy0.present = '"'TRUE'"' # setup VM with floppy
echo displayName = '"'$NVM'"' # name of virtual machine
echo guestOS = '"'$NVMOS'"'
echo
echo ide0:0.present = '"'TRUE'"'
echo ide0:0.deviceType = '"'cdrom-raw'"'
echo ide:0.startConnected = '"'false'"' # CDROM enabled
echo floppy0.startConnected = '"'FALSE'"'
echo floppy0.fileName = '"'/dev/fd0'"'
echo Ethernet0.present = '"'TRUE'"'
echo Ethernet0.networkName = '"'VM Network'"' # Default network
echo Ethernet0.addressType = '"'vpx'"'
echo
echo scsi0.present = '"'true'"'
echo scsi0.sharedBus = '"'none'"'
echo scsi0.virtualDev = '"'lsilogic'"'
echo scsi0:0.present = '"'true'"' # Virtual Disk Settings
echo scsi0:0.fileName = '"'$NVM.vmdk'"'
echo scsi0:0.deviceType = '"'scsi-hardDisk'"'
echo
# close file
exec 1>&-
# make stdout a copy of FD 6 (reset stdout), and close FD6
exec 1>&6
exec 6>&-
# Change permissions on the file so it can be executed by anyone
chmod 755 /vmfs/volumes/storage1/$NVMDIR/$NVM.vmx
#Creates 4gb Virtual disk
cd /vmfs/volumes/storage1/$NVMDIR #change to the VM dir
vmkfstools -c $NVMSIZE $NVM.vmdk -a lsilogic
#Register VM
vmware-cmd -s register /vmfs/volumes/storage1/$NVMDIR/$NVM.vmx
/////


