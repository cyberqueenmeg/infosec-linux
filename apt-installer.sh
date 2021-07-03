#!/usr/bin/env bash

#function to echo a line between segments
line() {
    echo "----------------------------------"
}

#function to install the layer 2 hypervisor, VirtualBox
installVirtualBox() {
#Check for VBox
VBoxCheck=$(whereis virtualbox)

if [[ $VBoxCheck == *"/usr/bin"* ]]; then
    echo "VirtualBox is installed!"
    echo "We will now begin installing the InfoSec Linux templates that you want."
    ./template-installer.sh
else
    echo "VirtualBox is not installed"
    echo "The script is now installing VirtualBox"
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add - 
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add - 
    sudo apt-get update --noconfirm
    sudo apt-get install virtualbox-6.1 --noconfirm
    sudo apt install virtualbox-ext-pack --noconfirm
    $(line)
    echo "We will now begin installing the InfoSec Linux templates that you want."
    ./template-installer.sh
fi


echo "Welcome to the InfoSec Linux APT installer."
$(line)
$(installVirtualBox)

