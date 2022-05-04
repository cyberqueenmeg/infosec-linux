#!/bin/bash

echo "Welcome to the InfoSec Linux Virtual Machine Setup Wizard!"
echo ""

echo "To run this program, you need to install VirtualBox and wGet. The VirtualBox extension pack is highly recommended."
echo "Do you have all of these programs installed? (y/n)"
echo ""
read dependencies

if [ "$dependencies" = "n" ] || [ "$dependencies" = "N" ]; then
	echo "Please install these dependencies and restart the program"
	echo "Exiting..."
	exit 1
fi

if [ "$dependencies" != "y" ] && [ "$dependencies" != "Y" ] && [ "$dependencies" != "n" ] && [ "$dependencies" != "N" ]; then
	echo "An error has occured"
	echo "Please enter y or Y for yes or n or N for no"
	echo "Exiting..."
	exit 1
fi

echo "Would you like to install a cybersecurity OS or a generic OS right now?"
echo "Select 1 for cybersecurity and select 2 for generic"

read selection

if [ "$selection" = "1" ] || [ "$selection" = "2" ]; then
    if [ "$selection" = 1 ]; then
        echo "Which cybersecurity operating system would you like to install right now? Please enter only one value."
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
        echo "10 - Honeydrive Web Application Penetration Testing (Honeypot maker)"
        echo "11 - Security Dojo Hacking Distribution"
        echo "12 - Pentoo"
        echo "13 - Remnux Malware Analysis"
        echo "14 - InfoSec Linux Malware Analysis"
        echo "15 - InfoSec Linux Mobile Hacking"
        echo "16 - InfoSec Linux Web App Hacking"
        read cyberselection
        if [ "$cyberselection" == "1" ]; then
            #user needs to run 'sudo apt update && apt upgrade' after download
            wget https://kali.download/virtual-images/kali-2022.1/kali-linux-2022.1-virtualbox-amd64.ova
            VBoxManage import kali-linux-2022.1-virtualbox-amd64.ova --accept-license
	    fi
        if [ "$cyberselection" == "2" ]; then
            #user needs to run 'sudo apt How to Import a Python Function fro...update && apt upgrade' after download
            wget http://deb.parrot.sh/parrot/iso/5.0/Parrot-security-5.0_amd64.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name Parrot-security-5.0_amd64.iso
            VBoxManage startvm $(vmname)
	    fi
        if [ "$cyberselection" == "3" ]; then
            #user needs to run 'sudo pacman -Syu' after download
            wget https://mirrors.fosshost.org/blackarch/ova/blackarch-linux-2021.09.01.ova
            VBoxManage import blackarch-linux-2021.09.01.ova
	    fi
        if [ "$cyberselection" == "4" ]; then
            #user needs to run 'sudo dnf upgrade --refresh && reboot'
            wget https://download.fedoraproject.org/pub/alt/releases/35/Labs/x86_64/iso/Fedora-Security-Live-x86_64-35-1.2.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name Fedora-Security-Live-x86_64-35-1.2.iso
            VBoxManage startvm $(vmname)
	    fi
        if [ "$cyberselection" == "5" ]; then
            #user needs to run 'sudo soup'
            wget https://download.securityonion.net/file/securityonion/securityonion-2.3.120-20220425.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name securityonion-2.3.120-20220425.iso
            VBoxManage startvm $(vmname)
	    fi
        if [ "$cyberselection" == "6" ]; then
            #user needs to update from manager GUI
            wget https://atxfiles.netgate.com/mirror/downloads/pfSense-CE-2.6.0-RELEASE-amd64.iso.gz
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name pfSense-CE-2.6.0-RELEASE-amd64.iso.gz
            VBoxManage startvm $(vmname)
	    fi
        if [ "$cyberselection" == "7" ]; then
            #user needs to run 'sudo apt update && apt upgrade' after download
            wget https://deb.parrot.sh/direct/parrot/iso/caine/caine12.4.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name caine12.4.iso
            VBoxManage startvm $(vmname)
	    fi
        if [ "$cyberselection" == "8" ]; then
            wget http://downloads.csilinux.com/CSI%20Linux%202021.2.ova
            VBoxManage import CSI-Linux-2021.2.ova
	    fi
        if [ "$cyberselection" == "9" ]; then
            #user needs to run 'sudo apt update && apt upgrade' after download
            wget https://download.tracelabs.org/TL-OSINT-2022.1-amd64.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname)
            VBoxManage startvm $(vmname) --name TL-OSINT-2022.1-amd64.iso
	    fi
        if [ "$cyberselection" == "10" ]; then
		    #user needs to run 'sudo apt update && apt upgrade' after download. It will take a while since it's based on Xubuntu 12.
		    wget https://downloads.sourceforge.net/project/honeydrive/HoneyDrive%203%20Royal%20Jelly%20edition/HoneyDrive_3_Royal_Jelly.ova?ts=gAAAAABiaBz_eLxLj3zXZSe_hb9HySo5Uwu5WXGb2eki2bnhFoOGbjYY_JD1oc5UTriKNw2BX8IGuPnKBVxQPC8LrMMYLTqcQg%3D%3D&r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fhoneydrive%2Ffiles%2Flatest%2Fdownload
		    VBoxManage import HoneyDrive_3_Royal_Jelly.ova
	    fi
        if [ "$cyberselection" == "11" ]; then
		    #user needs to run 'sudo apt update && apt upgrade' after download.
		    wget https://downloads.sourceforge.net/project/websecuritydojo/Version_3.4.1/Dojo-3.4.1.ova?ts=gAAAAABiaB0j24e0pxLqcRhnkLLDMkuYzcD_W5jqAu_vic8i4B8Y6Hz1A5rLirpSyhopFuf55UFr1AAurWSVvl2wWB2GNJdFPA%3D%3D&r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fwebsecuritydojo%2Ffiles%2Flatest%2Fdownload
		    VBoxManage import Dojo-3.4.1.ova
	    fi
        if [ "$cyberselection" == "12" ]; then
            #user needs to run 'emerge --ask --oneshot sys-apps/portage' after download.
            wget https://pentoo.osuosl.org/daily-autobuilds/Pentoo_Full_x86_hardened/pentoo-full-x86-hardened-2022.0_p20220312.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name pentoo-full-x86-hardened-2022.0_p20220312.iso
            VBoxManage startvm $(vmname)
	    fi
        if [ "$cyberselection" == "13" ]; then
		    wget https://downloads.sourceforge.net/project/remnux/ova-virtualbox/remnux-v7-focal-virtualbox.ova?ts=gAAAAABiaIIa5bKzzKa6qSt5WzjNFWjsz0ZpukfPxVLExVDmJVfr-R6y-WBLVt4HB_pwvBdFK68BuphnDED3A11z7ca-cb_tPA%3D%3D&r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fremnux%2Ffiles%2Fova-virtualbox%2Fremnux-v7-focal-virtualbox.ova%2Fdownload
		    VBoxManage import remnux-v7-focal-virtualbox.ova
        fi
        if [ "$cyberselection" == "14" ]; then
            wget https://github.com/cyberqueen-meg/infosec-linux/blob/main/virtual-machines/infoseclinux-malwareanalysis.vbox
            VBoxManage import infoseclinux-malwareanalysis.vbox 
        fi
        if [ "$cyberselection" == "15" ]; then
            wget https://github.com/cyberqueen-meg/infosec-linux/blob/main/virtual-machines/infoseclinux-mobilehacking.vbox
            VBoxManage import infoseclinux-mobilehacking.vbox
	    fi   
        if [ "$cyberselection" == "16" ]; then
            wget https://github.com/cyberqueen-meg/infosec-linux/blob/main/virtual-machines/infoseclinux-malwareanalysis.vbox
            VBoxManage import infoseclinux-webapphacking.vbox 
	    fi
    fi
    if [ "$selection" = "2" ]; then
        echo "Which generic operating system would you like to install right now? Please enter only one value."
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
        echo "14 - Arco Linux (Cinnamon)"
        echo "15 - Parrot Home"
        echo "16 - Solus"
        echo "17 - Zorin OS"
        echo "18 - POP! OS"
        echo "19 - Raspbian"
        echo "20 - FreeBSD"
        echo "21 - airyx OS"

        read genericselection
        if [ "$genericselection" == "1" ]; then
            wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-11.3.0-amd64-netinst.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name debian-11.3.0-amd64-netinst.iso
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "2" ]; then
            wget https://releases.ubuntu.com/22.04/ubuntu-22.04-desktop-amd64.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name ubuntu-22.04-desktop-amd64.iso
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "3" ]; then
            wget https://releases.ubuntu.com/20.04.4/ubuntu-20.04.4-live-server-amd64.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name ubuntu-20.04.4-live-server-amd64.iso
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "4" ]; then
            wget https://download.fedoraproject.org/pub/fedora/linux/releases/35/Workstation/x86_64/iso/Fedora-Workstation-Live-x86_64-35-1.2.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name Fedora-Workstation-Live-x86_64-35-1.2.iso 
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "5" ]; then
            wget https://download.fedoraproject.org/pub/fedora/linux/releases/35/Server/x86_64/iso/Fedora-Server-dvd-x86_64-35-1.2.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name Fedora-Server-dvd-x86_64-35-1.2.iso
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "6" ]; then
            wget https://download.opensuse.org/distribution/leap/15.3/iso/openSUSE-Leap-15.3-DVD-x86_64-Current.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name openSUSE-Leap-15.3-DVD-x86_64-Current.iso
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "7" ]; then
            wget http://mirror.arizona.edu/centos/7.9.2009/isos/x86_64/CentOS-7-x86_64-Everything-2009.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name CentOS-7-x86_64-Everything-2009.iso
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "8" ]; then
            wget https://yum.oracle.com/ISOS/OracleLinux/OL8/u5/x86_64/OracleLinux-R8-U5-x86_64-dvd.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name OracleLinux-R8-U5-x86_64-dvd.iso
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "9" ]; then
            wget https://yum.oracle.com/ISOS/OracleLinux/OL7/u9/x86_64/OracleLinux-R7-U9-Server-x86_64-dvd.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name OracleLinux-R7-U9-Server-x86_64-dvd.iso
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "10" ]; then
            https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20220424T170534Z/livegui-amd64-20220424T170534Z.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname) --name
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "11" ]; then
            wget https://download.manjaro.org/xfce/21.2.6/manjaro-xfce-21.2.6-220416-linux515.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname)
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "12" ]; then
            wget https://gitlab.archlinux.org/archlinux/arch-boxes/-/jobs/54317/artifacts/file/output/Arch-Linux-x86_64-virtualbox-20220426.54317.box
            VBoxManage import --name vmname -n
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname)
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "13" ]; then
            wget https://github.com/endeavouros-team/ISO/releases/download/1-EndeavourOS-ISO-releases-archive/EndeavourOS_Apollo_22_1.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname)
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "14" ]; then
            wget https://sourceforge.net/projects/arcolinux-community-editions/files/cinnamon/arcolinuxb-cinnamon-v22.03.07-x86_64.iso/download
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname)
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "15" ]; then
            wget http://deb.parrot.sh/parrot/iso/5.0/Parrot-home-5.0_amd64.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname)
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "16" ]; then
            wget https://mirrors.rit.edu/solus/images/4.3/Solus-4.3-Budgie.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname)
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "17" ]; then
            wget http://deb.parrot.sh/parrot/iso/zorin/Zorin-OS-16-Core-64-bit-r4.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname)
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "18" ]; then
            wget https://pop-iso.sfo2.cdn.digitaloceanspaces.com/22.04/amd64/intel/4/pop-os_22.04_amd64_intel_4.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname)
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "19" ]; then
            wget https://downloads.raspberrypi.org/rpd_x86/images/rpd_x86-2021-01-12/2021-01-11-raspios-buster-i386.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname)
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "20" ]; then
            wget https://download.freebsd.org/releases/amd64/amd64/ISO-IMAGES/13.0/FreeBSD-13.0-RELEASE-amd64-bootonly.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname)
            VBoxManage startvm $(vmname)
	fi
        if [ "$genericselection" == "21" ]; then
            wget https://mirrors.nomadlogic.org/nightly/airyxOS_0.4.0pre2_f13_5030978304344064_amd64.iso
            echo "What do you want to name your VM?"
            read vmname
            VBoxManage createvm --name $(vmname)
            VBoxManage storagectl $(vmname) --bootable yes
            VBoxManage storageattach $(vmname)
            VBoxManage startvm $(vmname)
	fi
    fi
fi
    
