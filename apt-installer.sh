#!/usr/bin/env bash

echo "Welcome to the InfoSec Linux APT installer."
echo "----------------------------------"

#install the layer 2 hypervisor, VirtualBox

#Check for VBox
VBoxCheck=$(whereis virtualbox)

if [[ $VBoxCheck == *"/usr/bin"* ]]; then
    echo "VirtualBox is installed!"
    echo "----------------------------------"
    echo "We will now begin installing the InfoSec Linux templates that you want."
    ./template-installer.sh
else
    echo "VirtualBox is not installed"
    echo "The script is now installing VirtualBox"
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add - 
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add - 
    sudo apt-get update
    sudo apt-get install virtualbox-6.1 
    sudo apt install virtualbox-ext-pack 
    echo "----------------------------------"
    echo "We will now begin installing the InfoSec Linux templates that you want."
    ./template-installer.sh
fi
