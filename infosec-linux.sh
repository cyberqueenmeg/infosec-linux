#!/usr/bin/env bash

#function to echo a line between segments
line() {
    echo "----------------------------------"
}

#function to determine package manager to install InfoSec Linux with
packageManager() {
    echo "Before we start, the installer needs to know what package manager you use."
    echo "Please enter 1 if you use APT (Debian/Ubuntu and its derivatives), 2 if you use RPM (includes YUM and DNF, runs on RedHat/Fedora systems and their derivatives), 3 if you use Pacman (Arch Linux and its derivatives), and 4 if you use another package manager or a non-Linux system (includes macOS, Windows, and other Operating System types that don't use these package managers.)"
    read packageManager
    if [ $packageManger -eq 1 ]; then
        echo "Starting APT installation script"
        $(line)
        ./apt-installer.sh
    elif [ $packageManager -eq 2 ]; then
        echo "Starting RPM installation script"
        $(line)
        ./rpm-installer.sh
    elif [ $packageManager -eq 3 ]; then
        echo "Starting Pacman installation script"
        $(line)
        ./pacman-installer.sh
    elif [ $packageManager -eq 4 ]; then
        echo "We are sorry, but we do not offer a script to support your system at this time."
        echo "You can contribute support for your package manager to InfoSec Linux by creating a pull request at https://github.com/mhowell11/infosec-linux"
        echo "You may also run InfoSec Linux by installing a Linux distro using APT, RPM, or Pacman into a virtual machine, although performance may be downgraded."    
        echo "Sorry for the inconvenience and thank you for taking the time to explore InfoSec Linux. We hope you choose to contribute to the project by adding your package manager."
    else 
        echo "You entered an invalid input. Please enter 1 if you use APT (Debian/Ubuntu and its derivatives), 2 if you use RPM (includes YUM and DNF, runs on RedHat/Fedora systems and their derivatives), 3 if you use Pacman (Arch Linux and its derivatives), and 4 if you use another package manager or a non-Linux system (includes macOS, Windows, and other Operating System types that don't use these package managers.)"
        $(packageManager)
    fi
}

$(line)
echo "Welcome to the InfoSec Linux installer!"
echo "Please note that some software is proprietary. All software is legally acquired from official sources."
$(line)
$(packageManager)
