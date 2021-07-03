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
        ./template-installer.sh
    elif [[$virtualboxInstalled -eq 2]]; then
        echo "The script is now installing VirtualBox"
        sudo pacman -S virtualbox virtualbox-guest-iso
        sudo gpasswd -a $USERS vboxusers
        sudo modprobe vboxdrv
        yay -Syy
        yay -S virtualbox-ext-oracle
        sudo systemctl enable vboxweb.service
        sudo systemctl start vboxweb.service
        $(line)
        echo "We will now begin installing the InfoSec Linux templates that you want."
        ./template-installer.sh
    else
        echo "You did not enter a valid input. Please enter 1 if you already have VirtualBox installed and 2 if you do not already have VirtualBox installed."
        $(installVirtualBox)
    fi
}

echo "Welcome to the InfoSec Linux Pacman installer."
$(installVirtualBox)