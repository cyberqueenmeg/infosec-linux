#!/usr/bin/env bash

#select the package manager to install infosec-linux on to.
echo "----------------------------------"
echo "Welcome to the InfoSec Linux installer!"
echo "Please note that some software is proprietary. All software is legally acquired from official sources."
echo "----------------------------------"
echo "Before we start the installation, the script needs to detect what package manager you are using and if the package manager is supported by InfoSec Linux."

declare -A osInfo;
osInfo[/etc/redhat-release]=yum
osInfo[/etc/arch-release]=pacman
#osInfo[/etc/gentoo-release]=emerge - hoping to add support for Gentoo later
#osInfo[/etc/SuSE-release]=zypp - hoping to add SuSE support later
osInfo[/etc/debian_version]=apt

for f in ${!osInfo[@]}
do
    if [[ -f $f ]];then
        packageManager=${osInfo[$f]}
    fi
done


if [[ $packageManger == 'apt']]; then
    echo "Starting APT installation script"
    echo "----------------------------------"
    ./apt-installer.sh
elif [[ $packageManager == 'yum' ]]; then
    echo "Starting RPM installation script"
    echo "----------------------------------"
    ./rpm-installer.sh
elif [[ $packageManager == 'pacman' ]]; then
    echo "Starting Pacman installation script"
    echo "----------------------------------"
    ./pacman-installer.sh
else 
    echo "We are sorry, but we do not offer a script to support your system at this time."
    echo "You can contribute support for your package manager to InfoSec Linux by creating a pull request at https://github.com/mhowell11/infosec-linux"
    echo "You may also run InfoSec Linux by installing a Linux distro using APT, RPM, or Pacman into a virtual machine, although performance may be downgraded."    
    echo "Sorry for the inconvenience and thank you for taking the time to explore InfoSec Linux. We hope you choose to contribute to the project by adding your package manager."
fi 
