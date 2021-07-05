#!/usr/bin/env bash
echo "Welcome to the InfoSec Linux RPM installer."
echo "----------------------------------"

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
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | rpm --import - 
    sudo dnf virtualbox-guest-additions --noconfirm
    echo "----------------------------------"
    echo "We will now begin installing the InfoSec Linux templates that you want."
    ./template-installer.sh
fi
