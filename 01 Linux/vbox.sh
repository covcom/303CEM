
#!/bin/bash

# thanks to Jonathan Perkin for the script.
# https://www.perkin.org.uk

# before running the scrip make sure you download the latest Ubuntu Server iso image
# make sure the ISO variable matches the name of the iso image
# run this script from the directory containing the iso image

# full documentation can be found at https://www.virtualbox.org/manual/ch08.html

VM='PXE'
TYPE='Ubuntu_64'
ISO='ubuntu-16.04.1-server-amd64.iso'

# delete any existing vm with the chosen name
# you can list all vms using 'vboxmanage list vms'
# you can list all hdds using 'vboxmanage list hdds'
vboxmanage unregistervm $VM -delete

# create a 10GB “dynamic” disk
VBoxManage createhd --filename $VM.vdi --size 20000

# create a new VM using the appropriate OS type 'VBoxManage list ostypes'
VBoxManage createvm --name $VM --ostype $TYPE --register

# add a SATA controller with the dynamic disk attached
VBoxManage storagectl $VM --name "SATA Controller" --add sata --controller IntelAHCI
VBoxManage storageattach $VM --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $VM.vdi

# add an IDE controller with a DVD drive attached, and the install ISO inserted into the drive
VBoxManage storagectl $VM --name "IDE Controller" --add ide
VBoxManage storageattach $VM --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $ISO

# misc system settings
VBoxManage modifyvm $VM --ioapic on
VBoxManage modifyvm $VM --boot1 dvd --boot2 disk --boot3 none --boot4 none
VBoxManage modifyvm $VM --memory 1024 --vram 128
VBoxManage modifyvm $VM --nic1 bridged
VBoxManage modifyvm $VM --bridgeadapter1 en1

# boot up the server
# VBoxHeadless -s $VM
# VBoxManage startvm $VM --type headless
VBoxManage startvm $VM