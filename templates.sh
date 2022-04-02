#!/bin/bash

echo "Welcome to the InfoSec Linux Virtual Machine Setup Wizard!"
echo ""

declare -a selection
echo "Custom Cybersecurity Distributions"
echo "1 - Kali Linux (Generic/normal install)"
echo "2 - Parrot OS"
echo "3 - Black Arch (Full repository)"
echo "4 - Fedora Security"
echo "5 - SecurityOnion"
echo "6 - pfSense"
echo "7 - Caine Forensics"
echo "8 - CSI Linux"
echo "9 - Kali Linux (Trace Labs/Open Source Intelligence)"
echo "10 - Honeydrive Web Application Penetration Testing"
echo "11 - Security Dojo Hacking Distribution"
#Add 'custom' InfoSec Linux pentesting distros for specific purposes - malware analysis, mobile, etc
echo "Generic Operating Systems for everyday use or to use as targets"
#add version numbers
echo "Debian"
echo "Ubuntu Desktop"
echo "Ubuntu Server"
echo "Fedora"
echo "Fedora Server"
echo "openSUSE"
echo "CentOS"
echo "Oracle Linux (Desktop)"
echo "Oracle Linux Server"
echo "Pear OS"
echo "Solaris"
echo "FreeBSD"
echo "airyx"

#Specialty operating systems
echo "AcademiX"
echo "Ubuntu Studio"
echo "Fedora Robotics"
echo "Scientific Linux"


echo "Which template would you like to install?"

read -r -p "Options: " selection
selection=${selection:- 1}
	for entry in $selection ;do

	case "${entry[@]}" in

		1)
		arch-chroot /mnt pacman -S plasma kde-applications --noconfirm 
		;;
		
		2)
		arch-chroot /mnt pacman -S xfce4 xfce4-goodies --noconfirm 
		;;
		
		3)
		arch-chroot /mnt pacman -S gnome --noconfirm
		arch-chroot /mnt systemctl enable gdm.service
		;;
		
		4)
		arch-chroot /mnt pacman -S cinnamon xterm --noconfirm 
		;;
		
		5)
		arch-chroot /mnt pacman -S budgie-desktop xterm --noconfirm 
		;;
		
		6)
		arch-chroot /mnt pacman -S mate mate-extra ttf-freefont --noconfirm 
		;;
