#!/usr/bin/env bash

#function to echo a line between segments
line() {
    echo "----------------------------------"
}

#function to install the layer 2 hypervisor, VirtualBox
installVirtualBox() {
    echo "To know where to start, we need to know if you already have VirtualBox installed. Please press 1 if you have VirtualBox installed and 2 if you do not have VirtualBox installed."
read virtualboxInstalled
$(line)
if [[$virtualboxInstalled -eq 1]]; then
    echo "We will now begin installing the InfoSec Linux templates that you want."
elif [[$virtualboxInstalled -eq 2]]; then
    echo "The script is now installing VirtualBox"
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install virtualbox-6.1
    $(line)
    echo "We will now begin installing the InfoSec Linux templates that you want."
else
    echo "You did not enter a valid input. Please enter 1 if you already have VirtualBox installed and 2 if you do not already have VirtualBox installed."
    $(installVirtualBox)
fi



echo "Welcome to the InfoSec Linux APT installer."
$(line)
$(installVirtualBox)

