#!/usr/bin/env bash

#select the package manager to install infosec-linux on to.
echo "----------------------------------"
echo "Welcome to the InfoSec Linux installer!"
echo "Please note that some software is proprietary. All software is legally acquired from official sources."
echo "----------------------------------"
echo "Before we start the installation, the script needs to detect what package manager you are using and if the package manager is supported by InfoSec Linux."
echo "----------------------------------"

if [ -x "$(command -v apt-get)" ]; then 
    echo "APT Package Manager Detected"
    echo "Starting APT installation script"
    echo "----------------------------------"
    ./apt-installer.sh
elif [ -x "$(command -v dnf)" ]; then
    echo "DNF Package Manager Detected"
    echo "Starting Fedora installation script"
    echo "----------------------------------"
    ./fedora-installer.sh
elif [ -x "$(command -v pacman)" ]; then
    echo "Pacman Package Manager Detected"
    echo "Starting Pacman installation script"
    echo "----------------------------------"
    ./pacman-installer.sh
    
else 
    echo "We are sorry, but we do not offer a script to support your detected package manager at this time."
    echo "You can contribute support for your package manager to InfoSec Linux by creating a pull request at https://github.com/mhowell11/infosec-linux"
    echo "You may also run InfoSec Linux by installing a Linux distro using APT, RPM, or Pacman into a virtual machine, although performance may be downgraded."    
    echo "Sorry for the inconvenience and thank you for taking the time to explore InfoSec Linux. We hope you choose to contribute to the project by adding your package manager."
fi 
