#!/bin/bash

echo "Welcome to the InfoSec Linux Virtual Machine Setup Wizard!"
echo ""

remoterepo = "http://infoseclinux.me" # need file path - will add later

declare -a selection

echo "Would you like to install a cybersecurity OS or a generic OS right now?"
echo "Select 1 for cybersecurity and select 2 for generic"

read -r -p "Options: " selection
selection=${selection:- 1}
	for entry in $selection ;do

	case "${entry[@]}" in

		1)
		echo "Which cybersecurity operating system would you like to install right now?"
		declare -a cyberselection
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

		read -r -p cyberselection
		cyberselection=${cyberselection:- 1}
			for entry in $cyberselection ;do

			case "${entry[@]}" in
				1)
				#user needs to run 'sudo apt update && apt upgrade' after download
				wget https://kali.download/virtual-images/kali-2022.1/kali-linux-2022.1-virtualbox-amd64.ova
				;;

				2)
				#user needs to run 'sudo apt update && apt upgrade' after download
				wget http://deb.parrot.sh/parrot/iso/5.0/Parrot-security-5.0_amd64.iso
				;;
				
				3)
				#user needs to run 'sudo pacman -Syu' after download
				wget https://mirrors.fosshost.org/blackarch/ova/blackarch-linux-2021.09.01.ova
				;;
				
				4)
				#user needs to run 'sudo dnf upgrade --refresh && reboot'
				wget https://download.fedoraproject.org/pub/alt/releases/35/Labs/x86_64/iso/Fedora-Security-Live-x86_64-35-1.2.iso
				;;
				
				5)
				#user needs to run 'sudo soup'
				wget https://download.securityonion.net/file/securityonion/securityonion-2.3.120-20220425.iso
				;;
				
				6)
				#user needs to update from manager GUI
				wget https://atxfiles.netgate.com/mirror/downloads/pfSense-CE-2.6.0-RELEASE-amd64.iso.gz
				;;
				
				7)
				#user needs to run 'sudo apt update && apt upgrade' after download
				wget https://deb.parrot.sh/direct/parrot/iso/caine/caine12.4.iso
				;;
				
				8)
				wget http://downloads.csilinux.com/CSI%20Linux%202021.2.ova
				;;
				
				9)
				#user needs to run 'sudo apt update && apt upgrade' after download
				wget https://download.tracelabs.org/TL-OSINT-2022.1-amd64.iso
				;;
				
				10)
				;;
				
				11)
				;;
				
				
		;;
		
		2)
		echo "Which generic operating system would you like to install right now?"
		declare -a genericselection
		#add version numbers
		echo "1 - Debian"
		echo "2 - Ubuntu Desktop"
		echo "3 - Ubuntu Server"
		echo "4 - Fedora"
		echo "5 - Fedora Server"
		echo "6 - openSUSE"
		echo "7 - CentOS"
		echo "8 - Oracle Linux (Desktop)"
		echo "9 - Oracle Linux Server"
		echo "10 - Gentoo"
		echo "11 - Manjaro Linux"
		echo "12 - Arch Linux"
		echo "13 - Endeavour OS"
		echo "14 - Arco Linux"
		echo "15 - Parrot Home"
		echo "16 - Solus"
		echo "17 - Zorin OS"
		echo "18 - POP! OS"
		echo "19 - Raspbian"
		echo "20 - Pear OS"
		echo "21 - Solaris"
		echo "22 - FreeBSD"
		echo "23 - airyx"
		


		read -r -p genericselection
		genericselection=${genericselection:- 1}
			for entry in $genericselection ;do

			case "${entry[@]}" in
				1)
				;;

				2)
				;;

				#etc
		;;
