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

/////////spec for the current server 

credentials are :
username: root
password: root*2023 
my ip address 192.168.58.27 255.255.255.0
Starting Nmap 7.80 ( https://nmap.org ) at 2024-03-11 12:17 CET
Nmap scan report for 192.168.58.10 (#virtual machine hosting vmware)
Host is up (0.00056s latency).
Not shown: 990 filtered ports
PORT     STATE  SERVICE
22/tcp   closed ssh
80/tcp   open   http
427/tcp  open   svrloc
443/tcp  open   https
902/tcp  open   iss-realsecure
5988/tcp closed wbem-http
5989/tcp open   wbem-https
8000/tcp open   http-alt
8300/tcp open   tmi
9080/tcp open   glrpc
MAC Address: C4:34:6B:93:D7:A4 (Hewlett Packard)

Nmap scan report for 192.168.58.30 (#virtual machine hosting vmware)
Host is up (0.00077s latency).
Not shown: 990 filtered ports
PORT     STATE  SERVICE
22/tcp   closed ssh
80/tcp   open   http
427/tcp  open   svrloc
443/tcp  open   https
902/tcp  open   iss-realsecure
5988/tcp closed wbem-http
5989/tcp open   wbem-https
8000/tcp open   http-alt
8300/tcp open   tmi
9080/tcp open   glrpc
MAC Address: 00:50:56:64:13:8A (VMware)
//// constraints :
perform a rarp to get the ip address of the target machine
ssh not enabled on the openstack machine -> use CLI command chkconfig MODULE <on,off,reset> : chkconfig SSH on  
python installed on the openstack host specify -> use ansible ad-hoc ansible openstack -m setup and locate the interpreter file then use the python_version.yml playbook to specify the interpreter file
////// vm creating using esxi cli 
##### VM Creation Script #####################################
#Script Version 1.1
#Author David E. Hart
#Date 10-05-06
#
#--------+
# Purpose|
#--------+-----------------------------------------------------
# This script will create a VM with the following attributes;
# Virtual Machine Name = ScriptedVM
# Location of Virtual Machine = /VMFS/volumes/storage1/ScriptedVM
# Virtual Machine Type = "Microsoft Windows 2003 Standard"
# Virtual Machine Memory Allocation = 256 meg
#
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
NVMOS="winnetstandard" # Type of OS for Virtual Machine
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
The script in Code Listing 4.6 will create a virtual machine that has the
following characteristics:



 


  
A VM called ScriptedVM in a directory named ScriptedVM on
storage1

  
 A VM that will be assigned 256MB of memory

  
 A VM that will have a 4GB SCSI hard drive (lsilogic controller)

  
 A VM configured for a Windows 2003 standard operating system

  
A floppy drive assigned, not connected at startup

  
 A CD-ROM attached to the ESX server's CD-ROM drive, not connected
at startup

  
An Ethernet adapter connected to the VM Network, enabled at startup

 

The exec commands in the script are system-level commands in Linux to
set up the writing to, and saving of, the script file. It redirects the console
screen's output to the script file.The use of the echo commands in the script
sends the commands to the screen which are redirected to the file for
writing.The file is then closed and the virtual configuration file,VMX, is
saved.The permissions are changed on the configuration file so any user on
ESX can access the virtual machine.Then the script creates the virtual disk
and registers the VM with the ESX server.


Use the following process to set up your script on the ESX server:



 


  
 Log in locally or connect to your ESX server remotely.

  
 Log in with an ID that has root privileges (see Figure 4.9).
 //// comment


