#!/usr/bin/env bash

#function to install the layer 2 hypervisor, VirtualBox
installVirtualBox() {
    echo "First we will check for necessary dependencies."
    #Check for VBox
    VBoxCheck=$(whereis virtualbox)
    YayCheck=$(whereis yay)
    if [ $YayCheck = *"/usr/bin"* ]; then
        echo "Yay is installed - continuing on"
        echo "----------------------------------"
    else
        echo "Yay is not installed. Please enter your username so that we can automate the Yay installation."
        read username
        sudo pacman -S base-devel --noconfirm
        sudo pacman -S git --noconfirm
        cd /opt
        sudo git clone https://aur.archlinux.org/yay.git
        sudo chown -R $(username):users ./yay
        cd yay
        makepkg -si

    if [ $VBoxCheck = *"/usr/bin"* ]; then
        echo "VirtualBox is installed!"
        echo "We will now begin installing the InfoSec Linux templates that you want."
        ./template-installer.sh
    else
        echo "VirtualBox is not installed"
        echo "The script is now installing VirtualBox"
        echo "The script is now installing VirtualBox"
        sudo pacman -S virtualbox virtualbox-guest-iso --noconfirm
        sudo gpasswd -a $USER vboxusers
        sudo modprobe vboxdrv
        yay -Syy
        yay -S virtualbox-ext-oracle
        sudo systemctl enable vboxweb.service
        sudo systemctl start vboxweb.service
        echo "----------------------------------"
        echo "We will now begin installing the InfoSec Linux templates that you want."
        ./template-installer.sh
}

echo "Welcome to the InfoSec Linux Pacman installer."
echo "----------------------------------"
$(installVirtualBox)
