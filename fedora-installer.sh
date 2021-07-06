#!/usr/bin/env bash
echo "Welcome to the InfoSec Linux Fedora installer."
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
    wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo -P /etc/yum.repos.d/
    rpm --import https://www.virtualbox.org/download/oracle_vbox.asc
    dnf update
    dnf install @development-tools
    dnf install kernel-devel kernel-headers dkms qt5-qtx11extras  elfutils-libelf-devel zlib-devel
    dnf install VirtualBox-6.1
    echo "----------------------------------"
    echo "We will now begin installing the InfoSec Linux templates that you want."
    ./template-installer.sh
fi
