#!/bin/bash


# Simple script to install Virtualbox with Extension Pack, create new VM in Run as sudo/root.


# Author: ekarlsson66@gmail.com
# Date: 2020-11-03
# Version: 001


# CLI Syntax: ./vbox_create.sh virtual_machine_name path/to/iso-file os_type.


vbm="$(VBoxmanage)"
vm="$1"
iso="$2"
os_type="$3"
v_hd="$vm"".vdi"


# Download VirtualBox Extension Pack.
wget "https://download.virtualbox.org/virtualbox/6.1.16/Oracle_VM_VirtualBox_Extension_Pack-6.1.16.vbox-extpack"

# Install Extension Pack.
"$vbm" extpack install \
	"Oracle_VM_VirtualBox_Extension_Pack-6.1.16.vbox-extpack" \
	&& "$vbm" extpack uninstall VNC

# Create a Virtual Machine.
"$vbm" createvm --name "$vm" --ostype "$os_type"

# Add 3 GB RAM.
"$vbm" modifyvm "$vm" --memory 3096

# Create Virtual hard drive. VDI name .
"$vbm" createhd --filename "$v_hd" --size 60000

# Set two CPU's.
"$vbm" modifyvm "$vm" --cpus 

# Add and attach VDI to VM.
"$vbm" storagectl "$vm" --name "SAS Controller" --add sas \
	--controller LSILogicSAS && "$vbm" storageattach "$vm" --storagectl \
	"SAS Controller" --port 0 --device 0 --type hdd --medium "$v_hd"

# Set SAS Controller.
"$vbm" storagectl "$v_hd" --name "SAS Controller" --hostiocache on 

# Set IDE Controller
"$vbm" storagectl "$v_hd" --name "IDE Controller" --add ide --controller PIIX4

# Attach OS ISO-file by path.
"$vbm" storageattach "$v_hd" --storagectl "IDE Controller" --port 0 \
	--device 0 --type dvddrive --medium "$iso"

# Prevent RAM slowdowns.
"$vbm" modifyvm "$v_hd" --nestedpaging on && "$vm" modifyvm "$v_hd" \
	--largepages on

# Create and start subnet, IP 10.0.0.0/24
"$vbm" natnetwork add --netname natnet1 --network "10.0.0.0/24" --enable && \
	"$vm" natnetwork start --netname natnet1

# Attach subnet to VM.
"$vbm" modifyvm "$v_hd" --nic1 natnetwork --nat-network1 natnet1 & pid=$!
wait "$pid"

# Activate VirtualBox VRDE-server, enabling RDP. 
"$vbm" modifyvm "$vm" --vrde on

#Set host port. Specified port has to be open on host. 
"$vbm" modifyvm "$vm" --vrdeport 5587

# Headless start of VM.
VBoxHeadless --startvm "$vm"


exit 0