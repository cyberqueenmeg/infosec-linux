#!/usr/bin/env bash
#Automated Arch Linux installation script originally by Alex "wailord284" Gaudino, modified by Megan Howell for InfoSec Linux.
###ABOUT###
#This script will autodetect a large range of hardware and should automatically configure many systems out of the box. It will install InfoSec Linux with the repo.


#Colors
yellow=$(tput setaf 3)
green=$(tput setaf 2)
red=$(tput setaf 1)
reset=$(tput sgr 0)
#Dialog prgbox
HEIGHT=42
WIDTH=135
#WIDTH=0 #0 auto sets
CHOICE_HEIGHT=40
#Dialog options for user input
dialogBacktitle="InfoSec Linux Installer"
dialogHeight=20
dialogWidth=80

#Welcome message
echo "$yellow""Please wait while the system clock and keyring are configured. This can take a moment.""$reset"


###CONFIGURE PACMAN###
#Stop the reflector.service as it sometimes fails. We sort mirrors later
systemctl stop reflector.service
#Set ArchISO to no siglevel. Needed for weird GPG errors or outdated Arch ISO
sed "s,SigLevel    = Required DatabaseOptional,SigLevel    = Never,g" -i /etc/pacman.conf
#Start the pacman key service
systemctl start pacman-init

#Add a known good worldwide mirrorlist. Current mirrors on arch ISO are broken(?)
cat << EOF > /etc/pacman.d/mirrorlist
Server = https://mirror.sfo12.us.leaseweb.net/archlinux/\$repo/os/\$arch
Server = https://mirror.arizona.edu/archlinux/\$repo/os/\$arch
Server = https://arch.hu.fo/archlinux/\$repo/os/\$arch
Server = https://mirrors.radwebhosting.com/archlinux/\$repo/os/\$arch
Server = https://mirror.lty.me/archlinux/\$repo/os/\$arch
Server = https://mirror.phx1.us.spryservers.net/archlinux/\$repo/os/\$arch
EOF


###SET TIME###
#Set time before init
#This is useful if you installed coreboot or have a dead RTC. The clock will have no time set by default and this will update it.
timedatectl set-ntp true
#Set hwclock as well in case system has no battery for RTC
pacman -Syy
pacman -S archlinux-keyring glibc ntp ncurses unzip wget dialog htop iotop --noconfirm
ntpd -qg
hwclock --systohc
gpg --refresh-keys
pacman-key --init
pacman-key --populate
clear


###WELCOME###
dialog --title "Welcome!" \
--backtitle "$dialogBacktitle" \
--timeout 20 \
--ok-label "Begin" \
--msgbox "$(printf %"s\n\n" "Welcome to the InfoSec Linux Installer!" "Please note, no changes will be made to the system until the final confirmation prompt at the end." "Press control + C to cancel at any time and return to the archiso.")" \
"$dialogHeight" "$dialogWidth"
clear


###USERNAME###
#Loop until the username passes the regex check
#Username must only be lowercase with numbers. Anything else fails
usernameCharacters="^[0-9a-z]+$"
#Loop until the username passes the regex check
while : ; do
	user=$(dialog --no-cancel --title "Username" \
		--backtitle "$dialogBacktitle" \
		--inputbox "Please enter a username. Must be lowercase only." "$dialogHeight" "$dialogWidth" 2>&1 > /dev/tty)
	user=${user:-arch}
	if [[ $user =~ $usernameCharacters ]]; then
		break #Exit loop if regex matches
	else
		dialog --msgbox "Username does not contain valid characters. Please try again with lowercase or numbers only." "$dialogHeight" "$dialogWidth" && clear
	fi
done
clear


###USER PASSWORD###
#Password input - run in a loop in case user enters wrong password
#For some reason 2>&1 needs to be first or else password gets displayed in the text field for a second when you press enter
while : ; do
	#pass1
	pass1=$(dialog --no-cancel --title "Password" \
		--backtitle "$dialogBacktitle" \
		--passwordbox "Please enter a password for user $user (Hidden)." "$dialogHeight" "$dialogWidth" 2>&1 > /dev/tty)
	pass1=${pass1:-pass}
	#pass2
	pass2=$(dialog --no-cancel --title "Password" \
		--backtitle "$dialogBacktitle" \
		--passwordbox "Please enter the same password again for user $user (Hidden)." "$dialogHeight" "$dialogWidth" 2>&1 > /dev/tty)
	pass2=${pass2:-pass}
	if [ "$pass1" = "$pass2" ]; then
		pass="$pass1"
		break #Exit loop if the passwords match
	else
		dialog --msgbox "The provided passwords do not match. Please try again." "$dialogHeight" "$dialogWidth" && clear
	fi
done
clear


###HOSTNAME###
#Hostname - for some reason 2>&1 needs to be first or else hostname doesnt work
host=$(dialog --no-cancel --title "Hostname" \
	--backtitle "$dialogBacktitle" \
	--inputbox "Please enter a hostname." "$dialogHeight" "$dialogWidth" 2>&1 > /dev/tty)
host=${host:-linux}
clear


###LOCALE###
COUNT=0
#Replace space with '+' to avoid splitting, then remove leading the #
for i in $(cat /etc/locale.gen | tail -n+24 | sed -e 's/  $//' -e 's, ,+,g' -e 's,#,,g') ; do
	COUNT=$((COUNT+1))
	MENU_OPTIONS="${MENU_OPTIONS} $i ${COUNT} off"
done
syslocale=(dialog --backtitle "$dialogBacktitle" \
	--title "Locale" \
	--scrollbar \
	--radiolist "Press space to select your locale." "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT")

options=(${MENU_OPTIONS})
locale=$("${syslocale[@]}" "${options[@]}" 2>&1 >/dev/tty)
locale=$(echo "${locale//+/ }")
clear


###TIMEZONE - COUNTRY###
unset COUNT MENU_OPTIONS options
COUNT=0
for i in /usr/share/zoneinfo/* ; do
	#Remove the directory path
	i=$(basename "$i")
	COUNT=$((COUNT+1))
	MENU_OPTIONS="${MENU_OPTIONS} $i ${COUNT} off"
done
systimezone=(dialog --backtitle "$dialogBacktitle" \
	--title "Timezone" \
	--scrollbar \
	--radiolist "Press space to select your timezone." "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT")
options=(${MENU_OPTIONS})
countryTimezone=$("${systimezone[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear


###TIMEZONE - CITY###
#Check to see if the country has additional timezones
unset COUNT MENU_OPTIONS options systimezone
if [ -d /usr/share/zoneinfo/"$countryTimezone" ]; then
	COUNT=0
	for i in /usr/share/zoneinfo/"$countryTimezone"/* ; do
		i=$(basename "$i")
		COUNT=$((COUNT+1))
		MENU_OPTIONS="${MENU_OPTIONS} $i ${COUNT} off"
	done
systimezone=(dialog --backtitle "$dialogBacktitle" \
	--title "Timezone" \
	--scrollbar \
	--radiolist "Press space to select the region in your timezone." "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT")
options=(${MENU_OPTIONS})
cityTimezone=$("${systimezone[@]}" "${options[@]}" 2>&1 >/dev/tty)
fi
clear


###DISK SELECTION###
declare -a storagePartitions
while : ; do
	#Choose disk to install to - $storage.
	unset COUNT MENU_OPTIONS options
	COUNT=-1
	mapfile -t dialogDiskSize < <(fdisk -l | grep "Disk /" | cut -d' ' -f 3,4 | sed -e 's, ,,g' -e 's,\,,,g')
	for i in $(fdisk -l | grep "Disk /" | cut -d ' ' -f 2 | sed -e 's,:,,g') ; do
		COUNT=$((COUNT+1))
		MENU_OPTIONS="${MENU_OPTIONS} $i ${dialogDiskSize[$COUNT]} off"
	done
	targetDisk=(dialog --backtitle "$dialogBacktitle" \
		--scrollbar \
		--title "Target installation drive" \
		--radiolist "Press space to select your drive. No data will be written at this point." "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT")
	options=(${MENU_OPTIONS})
	installDisk=$("${targetDisk[@]}" "${options[@]}" 2>&1 >/dev/tty)
	#Remove '|'
	storage=$(echo "$installDisk" | sed 's/|.*//')
	#Determine storage type for partitions - nvme0n1p1, sda1, vda1 or mmcblk0p1 - $storagePartitions
	if [[ "$storage" = /dev/nvme* ]]; then
		storagePartitions=([1]="$storage"p1 [2]="$storage"p2)
		break
	elif [[ "$storage" = /dev/mmcblk* ]]; then
		storagePartitions=([1]="$storage"p1 [2]="$storage"p2)
		break
	elif [[ "$storage" = /dev/vd* ]]; then
		storagePartitions=([1]="$storage"1 [2]="$storage"2)
		break
	elif [[ "$storage" = /dev/sd* ]]; then
		storagePartitions=([1]="$storage"1 [2]="$storage"2)
		break
	else
		dialog --msgbox "Invalid storage device enetered. Must be in the format of /dev/sd[a-z], /dev/vd[a-z], /dev/nvme0n1, /dev/mmcblk0." "$dialogHeight" "$dialogWidth" && exit 1
	fi
done
clear


###DISK SPACE CHECK###
#Make sure the drive is at least 8GB (8589934592 bytes)
#8589934592 / 1048576 = 8192MB (8GB)
driveSize=$(fdisk -l "$storage" | grep -m1 Disk | cut -d ":" -f 2 | cut -d "," -f 2 | sed -e 's/[^0-9]/ /g' -e 's/ //g')
if [ "$driveSize" -lt "8589934592" ]; then
	dialog --msgbox "Your target drive is smaller than 8GB. Please use a larger drive." "$dialogHeight" "$dialogWidth"
	exit 1
fi


###FILESYSTEM###
unset COUNT MENU_OPTIONS options
for i in $(echo "ext4 xfs f2fs jfs nilfs btrfs"); do
	COUNT=$((COUNT+1))
	MENU_OPTIONS="${MENU_OPTIONS} $i ${COUNT} off"
done
sysfilesystem=(dialog --backtitle "$dialogBacktitle" \
	--title "Filesystem" \
	--scrollbar \
	--radiolist "Press space to select your filesystem. EXT4 is the recommended choice if you are unsure." "$HEIGHT" "$WIDTH" "$CHOICE_HEIGHT")
options=(${MENU_OPTIONS})
filesystem=$("${sysfilesystem[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear


###ENCRYPTION###
#Ask user if they want disk encryption
#https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system
dialog --title "Disk Encryption" \
	--defaultno \
	--backtitle "$dialogBacktitle" \
	--yesno "$(printf %"s\n\n" "Do you want to enable disk encryption for the root partition?" "If you do not know what this means, you can safely press no.")" "$dialogHeight" "$dialogWidth" > /dev/tty 2>&1
optionEncrypt=$?
if [ "$optionEncrypt" = 0 ]; then
	encrypt="y"
else
	encrypt="n"
fi
clear


###ENCRYPTION PASSWORD###
#If user wants disk encryption, prompt them for a password twice
if [ "$encrypt" = y ]; then
while : ; do
	#encpass1
	encpass1=$(dialog --no-cancel --title "Disk Encryption Password" \
		--backtitle "$dialogBacktitle" \
		--passwordbox "Please enter a password to encrypt your disk (Hidden)." "$dialogHeight" "$dialogWidth" 2>&1 > /dev/tty)
	encpass1=${encpass1:-pass}
	#encpass2
	encpass2=$(dialog --no-cancel --title "Disk Encryption Password" \
		--backtitle "$dialogBacktitle" \
		--passwordbox "Please enter your password again to encrypt your disk (Hidden)." "$dialogHeight" "$dialogWidth" 2>&1 > /dev/tty)
	encpass2=${encpass2:-pass}
	if [ "$encpass1" = "$encpass2" ]; then
		encpass="$encpass1"
		break #Exit loop if encryption passwords match
	else
		dialog --msgbox "The provided passwords do not match. Please try again." "$dialogHeight" "$dialogWidth" && clear
	fi
done
fi
clear


###DISK WIPE###
dialog --title "Secure Disk Erase" \
	--defaultno \
	--backtitle "$dialogBacktitle" \
	--yesno "$(printf %"s\n\n" "Do you want to overwrite the drive with random data? This can take a long time depending on the size and speed of the drive." "This is also NOT recommended on any solid state media as it can shorten the devices life." "If you do not know what this means, you can safely press no.")" "$dialogHeight" "$dialogWidth" > /dev/tty 2>&1
optionWipe=$?
if [ "$optionWipe" = 0 ]; then
	wipe="y"
else
	wipe="n"
fi
clear

disableMitigations = "n"


###FINAL CONFIRMATION###
#Ask the user if they want to continue with the current options
#https://stackoverflow.com/questions/8467424/echo-newline-in-bash-prints-literal-n
dialog --backtitle "$dialogBacktitle" \
--title "Do you want to install with the following options?" \
--yesno "$(printf %"s\n" "Do you want to proceed with the installation? If you press yes, all data on the drive will be lost!" "Hostname: $host" "Username: $user" "Encryption: $encrypt" "Locale: $locale" "Country Timezone: $countryTimezone" "City Timezone: $cityTimezone" "Install Disk: $storage" "Secure Wipe: $wipe" "Custom Kernel: $installKernel" "Disable Mitigations: $disableMitigations" "Filesystem: $filesystem")" "$HEIGHT" "$WIDTH"
finalInstall=$?
if [ "$finalInstall" = 0 ]; then
	dialog --backtitle "$dialogBacktitle" \
	--title "Install starting!" \
	--timeout 5 --msgbox "Starting install in 5 seconds!" "$dialogHeight" "$dialogWidth"
	clear
else
	dialog --backtitle "$dialogBacktitle" \
	--title "Install canceled" \
	--msgbox "Press enter to quit." "$dialogHeight" "$dialogWidth"
	exit 1
fi


###DISK WIPE###
#Before starting, wipe the drive if user said y to wipe
if [ "$wipe" = y ]; then
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--prgbox "Erasing drive" "shred --verbose --random-source=/dev/urandom -n1 $storage" "$HEIGHT" "$WIDTH"
	clear
fi


###UEFI OR BIOS CHECK/SETUP###
#Boot type override. You can manually change this variable to the platform you want to install to.
#This is useful if youre installing on a 64bit uefi device but want a 32bit uefi boot (Ex. moving the drive to a different computer)
#Set boot override to 64 or 32
bootOverride=""
#Start the install - detect efi/uefi bios
#If efi is present in /sys/firmware/ then system is UEFI
if [ -d /sys/firmware/efi/ ]; then
	boot="efi" #Set boot to efi
else
	boot="bios" #Set boot to bios
fi
#Also detect the boot arch. Some platforms have a 32bit uefi (NOT to be confused with 32bit cpu)
if [ "$boot" = "efi" ]; then
	bootArch="$(cat /sys/firmware/efi/fw_platform_size)"
fi
#Change boot arch if manually set above
if [ "$bootOverride" = 64 ]; then
	bootArch="64"
	boot="efi"
elif [ "$bootOverride" = 32 ]; then
	bootArch="32"
	boot="efi"
fi


###DISK PARTITIONING###
#Begin disk partitioning
if [ "$boot" = bios ] || [ "$boot" = efi ]; then
	#Wipe drive - "${storagePartitions[1]}" is boot partition
	#We use fdisk to write a new partition table, then wipe it all with wipefs. This should unpartition the drive.
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "Patitioning Disk" \
	--prgbox "Erasing dirve" "echo -e 'g\nw' | fdisk $storage && wipefs --all $storage" "$HEIGHT" "$WIDTH"
	if [ "$boot" = bios ]; then
		#BIOS needs msdos
		parted -s "$storage" mklabel msdos
	else
		#UEFI needs GPT
		parted -s "$storage" mklabel gpt
	fi
	#Create fat32 boot partition
	parted -a optimal -s "$storage" mkpart primary fat32 1MiB 512MiB
	#Mark partition 1 as bootable
	parted -s "$storage" set 1 boot on
	#Create ext4 root partition
	parted -a optimal -s "$storage" mkpart primary "$filesystem" 512MiB 100%

	#Format partitions for encryption
	if [ "$encrypt" = y ]; then
		clear
		#Run cryptsetup just in terminal, password will be piped in from $encpass
		echo "$green""Setting up disk encryption. Please wait.""$reset"
		echo "$encpass" | cryptsetup --iter-time 5000 --use-random --type luks2 --cipher aes-xts-plain64 --key-size 512 --pbkdf argon2id luksFormat "${storagePartitions[2]}"
		echo "$encpass" | cryptsetup open "${storagePartitions[2]}" cryptroot
		#Filesystem creation
		if [ "$filesystem" = ext4 ] ; then 
			dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
			--title "Patitioning Disk" \
			--prgbox "Formatting root partition" "mkfs.ext4 -L ArchRoot /dev/mapper/cryptroot" "$HEIGHT" "$WIDTH"
		elif [ "$filesystem" = xfs ] ; then
			dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
			--title "Patitioning Disk" \
			--prgbox "Formatting root partition" "mkfs.xfs -f -L ArchRoot /dev/mapper/cryptroot" "$HEIGHT" "$WIDTH"
		elif [ "$filesystem" = jfs ] ; then
			dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
			--title "Patitioning Disk" \
			--prgbox "Formatting root partition" "yes | mkfs.jfs -L ArchRoot /dev/mapper/cryptroot" "$HEIGHT" "$WIDTH"
		elif [ "$filesystem" = nilfs ] ; then
			dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
			--title "Patitioning Disk" \
			--prgbox "Formatting root partition" "yes | mkfs.nilfs2 -L ArchRoot /dev/mapper/cryptroot" "$HEIGHT" "$WIDTH"
		elif [ "$filesystem" = f2fs ] ; then
			dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
			--title "Patitioning Disk" \
			--prgbox "Formatting root partition" "mkfs.f2fs -f -l ArchRoot -O extra_attr,inode_checksum,sb_checksum,compression,encrypt /dev/mapper/cryptroot" "$HEIGHT" "$WIDTH"
		else
			#BTRFS
			dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
			--title "Patitioning Disk" \
			--prgbox "Formatting root partition" "mkfs.btrfs -f -L ArchRoot /dev/mapper/cryptroot" "$HEIGHT" "$WIDTH"
		fi

		#Mount the BTRFS root partition using -o compress=zstd
		if [ "$filesystem" = btrfs ] ; then
			mount -o compress-force=zstd,noatime /dev/mapper/cryptroot /mnt
		#Mount F2FS root partition using -o compress_algorithm=zstd
		elif [ "$filesystem" = f2fs ] ; then
			mount -o compress_algorithm=zstd /dev/mapper/cryptroot /mnt
		#Standard mount for everything else
		else
			mount -o noatime /dev/mapper/cryptroot /mnt
		fi
	else
		#Format partitions for no encyption
		if [ "$filesystem" = ext4 ] ; then
			dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
			--title "Patitioning Disk" \
			--prgbox "Formatting root partition" "mkfs.ext4 -L ArchRoot ${storagePartitions[2]}" "$HEIGHT" "$WIDTH"
		elif [ "$filesystem" = xfs ] ; then
			dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
			--title "Patitioning Disk" \
			--prgbox "Formatting root partition" "mkfs.xfs -f -L ArchRoot ${storagePartitions[2]}" "$HEIGHT" "$WIDTH"
		elif [ "$filesystem" = jfs ] ; then
			dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
			--title "Patitioning Disk" \
			--prgbox "Formatting root partition" "yes | mkfs.jfs -L ArchRoot ${storagePartitions[2]}" "$HEIGHT" "$WIDTH"
		elif [ "$filesystem" = nilfs ] ; then
			dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
			--title "Patitioning Disk" \
			--prgbox "Formatting root partition" "yes | mkfs.nilfs2 -L ArchRoot ${storagePartitions[2]}" "$HEIGHT" "$WIDTH"
		elif [ "$filesystem" = f2fs ] ; then
			dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
			--title "Patitioning Disk" \
			--prgbox "Formatting root partition" "mkfs.f2fs -f -l ArchRoot -O extra_attr,inode_checksum,sb_checksum,compression,encrypt ${storagePartitions[2]}" "$HEIGHT" "$WIDTH"
		else
			#BTRFS
			dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
			--title "Patitioning Disk" \
			--prgbox "Formatting root partition" "mkfs.btrfs -f -L ArchRoot ${storagePartitions[2]}" "$HEIGHT" "$WIDTH"
		fi

		#Mount the BTRFS root partition using -o compress=zstd
		if [ "$filesystem" = btrfs ] ; then
			mount -o compress-force=zstd,noatime "${storagePartitions[2]}" /mnt
		#Mount F2FS root partition using -o compress_algorithm=zstd
		elif [ "$filesystem" = f2fs ] ; then
			mount -o compress_algorithm=zstd "${storagePartitions[2]}" /mnt
		#Standard mount for everything else
		else
			mount -o noatime "${storagePartitions[2]}" /mnt
		fi
	fi

	#Mount and partition the boot partition
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "Patitioning Disk" \
	--prgbox "Formatting boot partition" "mkfs.vfat -n ArchBoot -F32 ${storagePartitions[1]}" "$HEIGHT" "$WIDTH"
	#Mount drives
	mkdir /mnt/boot
	mount -o noatime "${storagePartitions[1]}" /mnt/boot
fi
clear


###ADD INFOSECLINUX###
#Add infoseclinux to pacman.conf
cat << EOF >> /etc/pacman.conf
#Add mirror here once it's set up

###MIRRORLIST SORTING###
#Sort mirrors
dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
--title "Sorting mirrors" \
--prgbox "Please wait while mirrors are sorted" "pacman -Syy && pacman -S --needed reflector --noconfirm && reflector --verbose -f 15 --latest 25 --country US --protocol https --age 12 --sort rate --save /etc/pacman.d/mirrorlist" "$HEIGHT" "$WIDTH"
#Remove the following mirrors. For some reason they behave randomly
sed '/mirror.lty.me/d' -i /etc/pacman.d/mirrorlist
sed '/mirrors.kernel.org/d' -i /etc/pacman.d/mirrorlist


###BASE PACKAGE INSTALL#
#Begin base system install and install zlib-ng from aurmageddon
clear
dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
--title "Installing packages" \
--prgbox "Installing base and base-devel package groups" "pacstrap /mnt base base-devel zlib-ng iptables-nft jfsutils nilfs-utils nano git --noconfirm" "$HEIGHT" "$WIDTH"


###PACMAN SETUP###
#Enable some options in pacman.conf
sed "s,\#\VerbosePkgLists,VerbosePkgLists,g" -i /mnt/etc/pacman.conf
sed "s,\#\ParallelDownloads = 5,ParallelDownloads = 5,g" -i /mnt/etc/pacman.conf
sed "s,\#\Color,Color,g" -i /mnt/etc/pacman.conf
clear


###KERNEL, FIRMWARE AND MICROCODE INSTALLATION###
#Install additional software
dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
--title "Installing additional base software" \
--prgbox "Installing base and base-devel package groups" "arch-chroot /mnt pacman -S linux linux-headers linux-firmware mkinitcpio grub efibootmgr dosfstools mtools --noconfirm" "$HEIGHT" "$WIDTH"
#Install amd or intel ucode based on cpu
vendor=$(cat /proc/cpuinfo | grep -m 1 "vendor" | grep -o "Intel")
if [ "$vendor" = Intel ]; then
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "Autodetected Intel CPU" \
	--prgbox "Installing Intel Microcode" "arch-chroot /mnt pacman -S intel-ucode --noconfirm" "$HEIGHT" "$WIDTH"
else
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "Autodetected AMD CPU" \
	--prgbox "Installing AMD Microcode" "arch-chroot /mnt pacman -S amd-ucode --noconfirm" "$HEIGHT" "$WIDTH"
fi
clear


###ENCRYPTION HOOK - MKINITCPIO###
#Enable encryption mkinitcpio hooks if needed and set zstd compression
#ZSTD compression: https://kernelnewbies.org/Linux_5.9#Support_for_ZSTD_compressed_kernel.2C_ramdisk_and_initramfs
###Arch has now made ZSTD the default (over gzip), but uncommenting zstd doesnt hurt anything. LZ4 is slightly faster but uses more disk space.
if [ "$encrypt" = y ]; then
	sed "s,HOOKS=(base udev autodetect modconf block filesystems keyboard fsck),HOOKS=(base udev autodetect keyboard keymap modconf block encrypt filesystems fsck),g" -i /mnt/etc/mkinitcpio.conf
fi
sed "s,\#\COMPRESSION=\"zstd\",COMPRESSION=\"zstd\",g" -i /mnt/etc/mkinitcpio.conf
#sed "s,\#\COMPRESSION_OPTIONS=(),COMPRESSION_OPTIONS=(-9),g" -i /mnt/etc/mkinitcpio.conf


###FSTAB###
#Create FSTAB
genfstab -U /mnt >> /mnt/etc/fstab


###TIMEZONE###
#Set timezone
if [ -z "$cityTimezone" ]; then
	arch-chroot /mnt ln -sf /usr/share/zoneinfo/"$countryTimezone" /etc/localtime
else
	arch-chroot /mnt ln -sf /usr/share/zoneinfo/"$countryTimezone"/"$cityTimezone" /etc/localtime
fi


###LOCALE AND CLOCK###
#Set clock
sed "s,\#$locale,$locale,g" -i /mnt/etc/locale.gen
dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
--title "Configuring system..." \
--prgbox "Setting locale and system clock" "arch-chroot /mnt locale-gen && arch-chroot /mnt hwclock --systohc" "$HEIGHT" "$WIDTH"
#Set language
lang=$(echo "$locale" | cut -d ' ' -f 1)
echo "LANG=$lang" >> /mnt/etc/locale.conf


###HOSTNAME AND HOST FILE###
#Set hostname
echo "$host" >> /mnt/etc/hostname
#Set hostname and ip stuffs to /etc/hosts
cat << EOF > /mnt/etc/hosts
127.0.0.1	localhost
::1		localhost
127.0.1.1	$host.localdomain	$host
EOF
clear


###REPO AND KEY SETUP###
#Install repos to target - multilib, aurmageddon, archlinuxcn
cat << EOF >> /mnt/etc/pacman.conf
[multilib]
Include = /etc/pacman.d/mirrorlist
#Chia archlinux repo with many aur packages

EOF
#Add the ubuntu keyserver to gpg
echo "keyserver keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
echo "keyserver hkp://pgp.mit.edu:11371" >> /mnt/etc/pacman.d/gnupg/gpg.conf


### FINISH INSPECTING CODE HERE TOMORROW ###

###PACKAGE INSTALLATION###
#Install desktop and software
dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
--title "Installing essential window manager software" \
--prgbox "Installing desktop environment" "arch-chroot /mnt pacman -Syy && arch-chroot /mnt pacman -S --needed wget lxdm xorg xorg-server && arch-chroot /mnt systemctl enable lxdm.service" "$HEIGHT" "$WIDTH"
clear

#########DESKTOP PICKING################
declare -a selection
echo "$green""1$reset - Install KDE desktop"
echo "$green""2$reset - Install XFCE desktop"
echo "$green""3$reset - Install GNOME desktop"
echo "$green""4$reset - Install Cinnamon desktop"
echo "$green""5$reset - Install Budgie desktop"
echo "$green""6$reset - Install MATE desktop"

echo "$reset""Default option is:$green 1$""$reset"
echo "Enter$green 1-12$reset (seperated by spaces for multiple options including (q)uit) or$red q$reset to$red quit$reset"
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

###CORE SYSTEM SERVICES###
#Enable services
dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
--title "Enabling Services" \
--prgbox "Enabling core system services" "arch-chroot /mnt systemctl enable NetworkManager ntpdate ctrl-alt-del.target earlyoom zramswap lxdm linux-modules-cleanup logrotate.timer" "$HEIGHT" "$WIDTH"
#If the user is using BTRFS, enable BTRFS-scrub service
if [ "$filesystem" = btrfs ] ; then
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "Enabling monthly BTRFS Scrub timer" \
	--prgbox "Enabling BTRFS Scrub" "arch-chroot /mnt systemctl enable btrfs-scrub@-.timer" "$HEIGHT" "$WIDTH"
fi
#Enable fstrim if an ssd is detected using lsblk -d -o name,rota. Will return 0 for ssd
#This works however, if you install via usb itll detect the usb drive as nonrotational and enable fstrim
if lsblk -d -o name,rota | grep "0" > /dev/null 2>&1 ; then
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "Enabling FSTrim timer" \
	--prgbox "Enable FStrim" "arch-chroot /mnt systemctl enable fstrim.timer" "$HEIGHT" "$WIDTH"
fi
clear
#Enable prelockd, ananicy-cpp preload daemon if ram is over ~2GB
#https://github.com/hakavlad/prelockd https://wiki.archlinux.org/index.php/Preload
ramTotal=$(grep MemTotal /proc/meminfo | grep -Eo '[0-9]*')
if [ "$ramTotal" -gt "2000000" ]; then
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "Enabling Performance Services" \
	--prgbox "Enabling ananicy, prelock, preload, irqbalance and uresourced" "arch-chroot /mnt systemctl enable ananicy-cpp.service prelockd.service preload.service irqbalance uresourced" "$HEIGHT" "$WIDTH"
fi
clear
#Dbus-broker setup. Disable dbus and then enable dbus-broker. systemctl --global enables dbus-broker for all users
#https://wiki.archlinux.org/index.php/D-Bus#Alternative_Implementations
dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
--title "Enabling Services" \
--prgbox "Enabling dbus-broker" "arch-chroot /mnt systemctl disable dbus.service && arch-chroot /mnt systemctl enable dbus-broker.service && arch-chroot /mnt systemctl --global enable dbus-broker.service" "$HEIGHT" "$WIDTH"
clear


###GPU CHECK/SETUP###
#Determine installed GPU - by default we now install the stuff required for AMD/Intel since those just autoload drivers
#The below stuff is now set to install vulkan drivers and hardware decoding for correct hardware
dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
--title "Detecting hardware" \
--prgbox "Finding system graphics card" "pacman -S lshw --noconfirm" "$HEIGHT" "$WIDTH"
#https://www.cyberciti.biz/faq/linux-tell-which-graphics-vga-card-installed/
if lshw -class display | grep "Advanced Micro Devices" || dmesg | grep amdgpu > /dev/null 2>&1 ; then
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "Detecting hardware" \
	--prgbox "Found AMD Graphics card" "arch-chroot /mnt pacman -S amdvlk vulkan-radeon --noconfirm" "$HEIGHT" "$WIDTH"
fi
if lshw -class display | grep "Intel Corporation" || dmesg | grep "i915" > /dev/null 2>&1 ; then
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "Detecting hardware" \
	--prgbox "Found Intel Graphics card" "arch-chroot /mnt pacman -S vulkan-intel libva-intel-driver intel-media-driver --noconfirm" "$HEIGHT" "$WIDTH"
fi
#if lshw -class display | grep "Nvidia Corporation" || dmesg | grep "nouveau" > /dev/null 2>&1 ; then
#	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
#	--title "Detecting hardware" \
#	--prgbox "Found NVidia Graphics card" "arch-chroot /mnt pacman -S nvidia nvidia-utils nvidia-settings libxnvctrl --noconfirm" "$HEIGHT" "$WIDTH"
#fi
clear


###B43 FIRMWARE CHECK/SETUP###
#Detect b43 firmware wifi cards and install b43-firmware
if dmesg | grep -q 'b43-phy0 ERROR'; then
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "Detecting hardware" \
	--prgbox "Found B43 Broadcom Wireless card" "arch-chroot /mnt pacman -S b43-firmware --noconfirm" "$HEIGHT" "$WIDTH"
fi


###TTY NETWORK INTERFACES###
#Find all network interfaces, and add them to /etc/issue to display IP address
#for interface in $(netstat -i | cut -d" " -f 1 | sed -e 's/Kernel//g' -e 's/Iface//g' -e '/^$/d' | sort -u) ; do
#	echo "IP Address for $interface: \4{$interface}" >> /mnt/etc/issue
#done


###ANANICY SETUP###
#Change the default frequency ananicy checks system programs from 5 to 15 seconds
sed "s,check_freq=5,check_freq=15,g" -i /mnt/etc/ananicy.d/ananicy.conf


###NANO SETUP###
#Setup nano config
sed "s,\#\ set linenumbers, set linenumbers,g" -i /mnt/etc/nanorc
sed "s,\#\ set positionlog, set positionlog,g" -i /mnt/etc/nanorc
sed "s,\#\ set constantshow, set constantshow,g" -i /mnt/etc/nanorc
sed "s,\#\ set titlecolor bold\,white\,blue, set titlecolor bold\,lightwhite,g" -i /mnt/etc/nanorc
sed "s,\#\ set promptcolor lightwhite\,grey, set promptcolor lightwhite\,lightblack,g" -i /mnt/etc/nanorc
sed "s,\#\ set errorcolor bold\,white\,red, set errorcolor bold\,lightwhite\,red,g" -i /mnt/etc/nanorc
sed "s,\#\ set spotlightcolor black\,lightyellow, set spotlightcolor black\,lime,g" -i /mnt/etc/nanorc
sed "s,\#\ set selectedcolor lightwhite\,magenta, set selectedcolor lightwhite\,magenta,g" -i /mnt/etc/nanorc
sed "s,\#\ set stripecolor \,yellow, set stripecolor yellow,g" -i /mnt/etc/nanorc
sed "s,\#\ set statuscolor bold\,white\,green, set statuscolor bold\,white,g" -i /mnt/etc/nanorc
sed "s,\#\ set scrollercolor cyan, set scrollercolor cyan,g" -i /mnt/etc/nanorc
sed "s,\#\ set numbercolor cyan, set numbercolor magenta,g" -i /mnt/etc/nanorc
sed "s,\#\ set keycolor cyan, set keycolor cyan,g" -i /mnt/etc/nanorc
sed "s,\#\ set functioncolor green, set functioncolor green,g" -i /mnt/etc/nanorc
sed "s,\#\ include \"/usr/share/nano/\*.nanorc\", include \"/usr/share/nano/\*.nanorc\",g" -i /mnt/etc/nanorc
echo "include /usr/share/nano-syntax-highlighting/*.nanorc" >> /mnt/etc/nanorc


###SUDO SETUP###
#Add sudo changes
sed "s,\#\ %wheel ALL=(ALL:ALL) ALL,%wheel ALL=(ALL:ALL) ALL,g" -i /mnt/etc/sudoers
cat << EOF >> /mnt/etc/sudoers
Defaults timestamp_type=global
Defaults passwd_tries=5
Defaults passwd_timeout=0
Defaults env_reset,pwfeedback
Defaults editor=/usr/bin/rnano 
Defaults log_host, log_year, logfile="/var/log/sudo.log"
#$user ALL=(ALL) NOPASSWD:/usr/bin/pacman,/usr/bin/yay,/usr/bin/cpupower,/usr/bin/iotop,/usr/bin/poweroff,/usr/bin/reboot,/usr/bin/machinectl,/usr/bin/reflector"
EOF


###MAKEPKG SETUP###
#Setup makepkg config
#Change default -j count to use all cores
sed "s,\#\MAKEFLAGS=\"-j2\",MAKEFLAGS=\"-j\$(nproc)\",g" -i /mnt/etc/makepkg.conf
#Build all pkgs with native optimizations
sed "s,-mtune=generic,-mtune=native,g" -i /mnt/etc/makepkg.conf
#Enable link time optimizations
sed "s,\!lto,lto,g" -i /mnt/etc/makepkg.conf
#Build all rust pkgs with native optimizations
sed "s,\#\RUSTFLAGS=\"-C opt-level=2\",RUSTFLAGS=\"-C opt-level=2 -C target-cpu=native\",g" -i /mnt/etc/makepkg.conf
#Enable multithreaded compression support
sed "s,COMPRESSGZ=(gzip -c -f -n),COMPRESSGZ=(pigz -c -f -n),g" -i /mnt/etc/makepkg.conf
sed "s,COMPRESSBZ2=(bzip2 -c -f),COMPRESSBZ2=(pbzip2 -c -f),g" -i /mnt/etc/makepkg.conf
sed "s,COMPRESSXZ=(xz -c -z -),COMPRESSXZ=(xz -e -9 -c -z --threads=0 -),g" -i /mnt/etc/makepkg.conf
sed "s,COMPRESSZST=(zstd -c -z -q -),COMPRESSZST=(zstd -c --ultra -22 --threads=0 -),g" -i /mnt/etc/makepkg.conf
#Change default pkg extension to just tar (uncompressed)
sed "s,PKGEXT='.pkg.tar.zst',PKGEXT='.pkg.tar',g" -i /mnt/etc/makepkg.conf


###ENVIRONMENT VARIABLES###
#These variables help enforce config files out of the home directory
cat << EOF >> /mnt/etc/profile
#Environment variables to move files out of home directory
export XDG_CONFIG_HOME="\$HOME/.config"
export XDG_DATA_HOME="\$HOME/.local/share"
export XDG_CACHE_HOME="\$HOME/.cache"
export GTK2_RC_FILES="\${XDG_CONFIG_HOME}/gtk-2.0/gtkrc"
export GNUPGHOME="\${XDG_DATA_HOME}/gnupg"
export INPUTRC="\${XDG_CONFIG_HOME}/readline/inputrc"
export LESSHISTFILE="\${XDG_CACHE_HOME}/less/history"
export LESSKEY="\${XDG_CONFIG_HOME}/less/lesskey"
export npm_config_cache="\${XDG_CACHE_HOME}/npm"
export SCREENRC="\${XDG_CONFIG_HOME}/screen/screenrc"
export CARGO_HOME="\${XDG_CACHE_HOME}/cargo"
export GIMP2_DIRECTORY="\${XDG_CONFIG_HOME}/gimp"
EOF


###VIRTUAL MACHINE CHECK/SETUP###
#Detect if running in virtual machine and install guest additions
#$product - Sets to company that produces the system
#$hypervisor - Name of hypervisor software (extra check if dmidecode fails)
#$manufacturer - Systemd has built in tools to check for VM (extra extra check)
#https://www.ostechnix.com/check-linux-system-physical-virtual-machine/
dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
--title "Detecting virtual machine" \
--prgbox "Checking if system is a virtual machine" "pacman -S dmidecode --noconfirm" "$HEIGHT" "$WIDTH"
product=$(dmidecode -s system-product-name)
hypervisor=$(dmesg | grep "Hypervisor detected" | cut -d ":" -f 2 | tr -d ' ')
manufacturer=$(systemd-detect-virt)
if [ "$product" = "VirtualBox" ] || [ "$hypervisor" = "VirtualBox" ] || [ "$manufacturer" = "oracle" ]; then
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "Detecting virtual machine" \
	--prgbox "Running in VirtualBox - Installing guest additions" "arch-chroot /mnt pacman -S xf86-video-vmware virtualbox-guest-utils --noconfirm" "$HEIGHT" "$WIDTH"
elif [ "$product" = "Standard PC (i440FX + PIIX, 1996)" ] || [ "$hypervisor" = "KVM" ] || [ "$manufacturer" = "kvm" ]; then
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "Detecting virtual machine" \
	--prgbox "Running in KVM - Installing guest additions" "arch-chroot /mnt pacman -S qemu-guest-agent --noconfirm && arch-chroot /mnt systemctl enable qemu-guest-agent.service" "$HEIGHT" "$WIDTH"
elif [ "$product" = "VMware Virtual Platform" ] || [ "$hypervisor" = "VMware" ] || [ "$manufacturer" = "vmware" ]; then
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "Detecting virtual machine" \
	--prgbox "Running in VMWare - Installing guest additions" "arch-chroot /mnt pacman -S xf86-video-vmware xf86-input-vmmouse open-vm-tools --noconfirm && arch-chroot /mnt systemctl enable vmtoolsd.service vmware-vmblock-fuse.service" "$HEIGHT" "$WIDTH"
fi
clear


###USER CONFIG SETUP - /etc/skel###
#Download config files from github
dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
--title "Configuring system" \
--prgbox "Downloading config files" "wget https://github.com/wailord284/Arch-Linux-Installer/archive/master.zip && unzip master.zip && rm -r master.zip" "$HEIGHT" "$WIDTH"
#Create /etc/skel dirs for configs to be applied to our new user
mkdir -p /mnt/etc/skel/.config/gtk-3.0/
mkdir -p /mnt/etc/skel/.config/gtk-2.0/
mkdir -p /mnt/etc/skel/.config/readline/
mkdir -p /mnt/etc/skel/.config/kitty/
mkdir -p /mnt/etc/skel/.config/screen
mkdir -p /mnt/etc/skel/.config/wezterm/
mkdir -p /mnt/etc/skel/.local/share/xfce4/
#Move configs files to /etc/skel
#Move kitty config
mv Arch-Linux-Installer-master/configs/kitty.conf /mnt/etc/skel/.config/kitty/
#Move wezterm config/ We dont install wezterm by default
mv Arch-Linux-Installer-master/configs/wezterm.lua /mnt/etc/skel/.config/wezterm/
#Move picom config. We don't use picom, but maybe in the future
mv Arch-Linux-Installer-master/configs/picom.conf /mnt/etc/skel/.config/
#Create gtk-2.0 disable recents
mv Arch-Linux-Installer-master/configs/gtk-2.0/gtkrc /mnt/etc/skel/.config/gtk-2.0/
#Create gtk-3.0 disable recents
mv Arch-Linux-Installer-master/configs/gtk-3.0/settings.ini /mnt/etc/skel/.config/gtk-3.0/
#Create the xfce configs for a wayyy better desktop setup than the xfconfs
mv Arch-Linux-Installer-master/configs/xfce4/ /mnt/etc/skel/.config/
#Move mimelist - sets some default apps for file types
mv Arch-Linux-Installer-master/configs/mimeapps.list /mnt/etc/skel/.config/
#Default wallpaper from manjaro forum
mv Arch-Linux-Installer-master/configs/ArchWallpaper.jpeg /mnt/usr/share/backgrounds/xfce/
#Bash stuff and screenrc
mv Arch-Linux-Installer-master/configs/bash/inputrc /mnt/etc/skel/.config/readline/
mv Arch-Linux-Installer-master/configs/bash/screenrc /mnt/etc/skel/.config/screen/
mv Arch-Linux-Installer-master/configs/bash/.bashrc /mnt/etc/skel/
mv Arch-Linux-Installer-master/configs/bash/.bash_profile /mnt/etc/skel/


###USER AND PASSWORDS###
#Add user here to get /etc/skel configs
arch-chroot /mnt useradd -m -G network,input,kvm,floppy,audio,storage,uucp,wheel,optical,scanner,sys,video,disk -s /bin/bash "$user"
#reate a temp file to store the password in and delete it when the script finishes using a trap
#https://www.pixelstech.net/article/1577768087-Create-temp-file-in-Bash-using-mktemp-and-trap
TMPFILE=$(mktemp) || exit 1
trap 'rm -f "$TMPFILE"' EXIT
#Setup more secure passwd by increasing hashes
sed '/nullok/d' -i /mnt/etc/pam.d/passwd
echo "password required pam_unix.so sha512 shadow nullok rounds=65536" >> /mnt/etc/pam.d/passwd
#Create account passwords
echo "$user":"$pass" > "$TMPFILE"
arch-chroot /mnt chpasswd < "$TMPFILE"
#Set the root password
echo "root":"$pass" > "$TMPFILE"
arch-chroot /mnt chpasswd < "$TMPFILE"
#Unset the passwords stored in pass1 pass2 pass and encpass encpass1 encpass2
unset pass1 pass2 pass encpass encpass1 encpass2
#Setup stronger password security
#https://wiki.archlinux.org/index.php/Security#User_setup
#Increase delay between password attempts to 4 seconds
echo "auth optional pam_faildelay.so delay=4000000" >> /mnt/etc/pam.d/system-login


###FONTS###
#Set fonts 
#https://www.reddit.com/r/archlinux/comments/5r5ep8/make_your_arch_fonts_beautiful_easily/
arch-chroot /mnt ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
arch-chroot /mnt ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
arch-chroot /mnt ln -s /etc/fonts/conf.avail/10-hinting-full.conf /etc/fonts/conf.d
sed "s,\#export FREETYPE_PROPERTIES=\"truetype\:interpreter-version=40\",export FREETYPE_PROPERTIES=\"truetype\:interpreter-version=40\",g" -i /mnt/etc/profile.d/freetype2.sh


###NETWORKMANAGER###
#NetworkManager/Network startup scripts
mkdir -p /mnt/etc/NetworkManager/conf.d/
mkdir -p /mnt/etc/NetworkManager/dnsmasq.d/
#Configure mac address spoofing on startup via networkmanager. Only wireless interfaces are randomized
mv Arch-Linux-Installer-master/configs/networkmanager/rand_mac.conf /mnt/etc/NetworkManager/conf.d/
#IPv6 privacy and managed connection
cat << EOF >> /mnt/etc/NetworkManager/NetworkManager.conf
[connection]
ipv6.ip6-privacy=2
[ifupdown]
managed=true
EOF
#Use dnsmasq for dns - this is currently disabled - networkmanager sets resolv.conf to 127.0.0.1 when dns=dnsmasq
mv Arch-Linux-Installer-master/configs/networkmanager/dns.conf /mnt/etc/NetworkManager/conf.d/
echo "cache-size=1000" > /mnt/etc/NetworkManager/dnsmasq.d/cache.conf
echo "listen-address=::1" > /mnt/etc/NetworkManager/dnsmasq.d/ipv6_listen.conf
mv Arch-Linux-Installer-master/configs/networkmanager/dnssec.conf /mnt/etc/NetworkManager/dnsmasq.d/
#Set default DNS to cloudflare and quad9
mv Arch-Linux-Installer-master/configs/networkmanager/dns-servers.conf /mnt/etc/NetworkManager/conf.d/
#Set network manager to avoid systemd-resolved. Fixes issue "unit dbus-org.freedesktop.resolve1.service not found" in journal log
mv Arch-Linux-Installer-master/configs/networkmanager/no-systemd-resolve.conf /mnt/etc/NetworkManager/conf.d/
#Create one time ntpdupdate + hwclock to set date
mkdir -p /mnt/etc/systemd/system/ntpdate.service.d
mv Arch-Linux-Installer-master/configs/networkmanager/hwclock.conf /mnt/etc/systemd/system/ntpdate.service.d/


###UDEV RULES###
#IOschedulers for storage that supposedly increase perfomance
mv Arch-Linux-Installer-master/configs/udev/60-ioschedulers.rules /mnt/etc/udev/rules.d/
#HDParm rule to spin down drives after 20 idle minutes
mv Arch-Linux-Installer-master/configs/udev/69-hdparm.rules /mnt/etc/udev/rules.d/


###POLKIT RULES###
#Add polkit rule so users in KVM group can use libvirt (you don't need to be in the libvirt group now)
mv -f Arch-Linux-Installer-master/configs/polkit-1/50-libvirt.rules /mnt/etc/polkit-1/rules.d/
#Add gparted polkit rule for storage group, allow users to not enter a password
mv -f Arch-Linux-Installer-master/configs/polkit-1/00-gparted.rules /mnt/etc/polkit-1/rules.d/
#Add gsmartcontrol rule for storage group, allow users to not enter a password to view smart data
mv -f Arch-Linux-Installer-master/configs/polkit-1/50-gsmartcontrol.rules /mnt/etc/polkit-1/rules.d/
#Allow user in the network group to add/modify/delete networks without a password
mv -f Arch-Linux-Installer-master/configs/polkit-1/50-networkmanager.rules /mnt/etc/polkit-1/rules.d/
clear


###WACOM TABLET###
#Change to and if -d /proc/bus/input/devices/wacom
#Check and setup touchscreen - like x201T/x220T
if grep -i wacom /proc/bus/input/devices > /dev/null 2>&1 ; then
	mv Arch-Linux-Installer-master/configs/xorg/72-wacom-options.conf /mnt/etc/X11/xorg.conf.d/
fi


###LAPTOP SETUP###
#Check and setup laptop features
#Use hostnamectl to check the chassis type for laptop
chassisType=$(hostnamectl chassis)
if [ "$chassisType" = laptop ]; then
	#Move the powertop config so it can be enabled
	mv Arch-Linux-Installer-master/configs/systemd/powertop.service /mnt/etc/systemd/system/
	#Install power saving tools and enable tlp + powertop
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "Laptop Found" \
	--prgbox "Setting up powersaving features" "arch-chroot /mnt pacman -S powertop x86_energy_perf_policy xf86-input-synaptics tlp tlp-rdw --noconfirm && arch-chroot /mnt systemctl enable tlp.service powertop.service" "$HEIGHT" "$WIDTH"
	#Add touchpad config
	mv Arch-Linux-Installer-master/configs/xorg/70-synaptics.conf /mnt/etc/X11/xorg.conf.d/
	#Laptop mode
	mv Arch-Linux-Installer-master/configs/sysctl/00-laptop-mode.conf /mnt/etc/sysctl.d/
	#Disable watchdog - may help with power
	mv Arch-Linux-Installer-master/configs/sysctl/00-disable-watchdog.conf /mnt/etc/sysctl.d/
	#Set PCIE powersave in TLP
	sed "s,\#\PCIE_ASPM_ON_BAT=default,PCIE_ASPM_ON_BAT=powersupersave,g" -i /mnt/etc/tlp.conf
	#Increase dirty writeback time to 30 seconds
	mv Arch-Linux-Installer-master/configs/sysctl/50-dirty-writebacks.conf /mnt/etc/sysctl.d/
fi
clear


###MODULES###
#Load the tcp_bbr module for better network stuffs. This is utilized in the network sysctl config
echo 'tcp_bbr' > /mnt/etc/modules-load.d/tcp_bbr.conf


###SYSTEMD###
#Systemd services
#https://wiki.archlinux.org/index.php/Network_configuration#Promiscuous_mode - packet sniffing/monitoring
mv Arch-Linux-Installer-master/configs/systemd/promiscuous@.service /mnt/etc/systemd/system/
#Set journal to output log contents to TTY12
mkdir /mnt/etc/systemd/journald.conf.d
mv Arch-Linux-Installer-master/configs/systemd/fw-tty12.conf /mnt/etc/systemd/journald.conf.d/
#Set a lower systemd timeout
sed "s,\#\DefaultTimeoutStartSec=90s,DefaultTimeoutStartSec=45s,g" -i /mnt/etc/systemd/system.conf
sed "s,\#\DefaultTimeoutStopSec=90s,DefaultTimeoutStopSec=45s,g" -i /mnt/etc/systemd/system.conf
#Set journal to only keep 512MB of logs
mv Arch-Linux-Installer-master/configs/systemd/00-journal-size.conf /mnt/etc/systemd/journald.conf.d/
#Copy BTRFS file defrag service if filesystem is BTRFS
if [ "$filesystem" = btrfs ] ; then
	#Move the BTRFS defrag service and timer
	mv Arch-Linux-Installer-master/configs/systemd/btrfs-autodefrag.service /mnt/etc/systemd/system/
	mv Arch-Linux-Installer-master/configs/systemd/btrfs-autodefrag.timer /mnt/etc/systemd/system/
	#Enable the service. "/dev/null 2>&1" at the end hides the output of enabling the service
	arch-chroot /mnt systemctl enable btrfs-autodefrag.timer > /dev/null 2>&1
fi


###SYSCTL RULES###
#Low-level console messages
mv Arch-Linux-Installer-master/configs/sysctl/00-console-messages.conf /mnt/etc/sysctl.d/
#Allow unprivileged_userns_clone
mv Arch-Linux-Installer-master/configs/sysctl/00-unprivileged-userns.conf /mnt/etc/sysctl.d/
#IPv6 privacy
mv Arch-Linux-Installer-master/configs/sysctl/00-ipv6-privacy.conf /mnt/etc/sysctl.d/
#Kernel hardening
mv Arch-Linux-Installer-master/configs/sysctl/00-kernel-hardening.conf /mnt/etc/sysctl.d/
#System tweaks
mv Arch-Linux-Installer-master/configs/sysctl/30-system-tweak.conf /mnt/etc/sysctl.d/
#Network tweaks
mv Arch-Linux-Installer-master/configs/sysctl/30-network.conf /mnt/etc/sysctl.d/
#RAM and storage tweaks
mv Arch-Linux-Installer-master/configs/sysctl/50-dirty-bytes.conf /mnt/etc/sysctl.d/
#OOM Killer tweaks
mv Arch-Linux-Installer-master/configs/sysctl/00-oom-killer.conf /mnt/etc/sysctl.d/


###GRUB INSTALL###
#Grub install - support uefi 64 and 32
if [ "$boot" = efi ]; then
	if [ "$bootArch" = 64 ]; then
		dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
		--title "GRUB installation" \
		--prgbox "Installing grub for UEFI" "arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch --removable --recheck" "$HEIGHT" "$WIDTH"
	else
		dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
		--title "GRUB installation" \
		--prgbox "Installing grub for 32 bit UEFI" "arch-chroot /mnt grub-install --target=i386-efi --efi-directory=/boot --bootloader-id=Arch --removable --recheck" "$HEIGHT" "$WIDTH"
	fi
fi

if [[ "$boot" = bios ]]; then
	dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
	--title "GRUB installation" \
	--prgbox "Installing grub for legacy BIOS" "arch-chroot /mnt grub-install --target=i386-pc $storage --recheck" "$HEIGHT" "$WIDTH"
fi
clear


###GRUB BOOT OPTIONS###
#Check the output of cat /sys/power/mem_sleep for the systems sleep mode
#If the system is using s2idle but also has deep sleep mode availible, switch it to deep
#This is especially needed on the Framework laptop, although others may benefit
#https://www.kernel.org/doc/html/v4.18/admin-guide/pm/sleep-states.html
sleepMode=$(cat /sys/power/mem_sleep)
if [ "$sleepMode" = "[s2idle] deep" ]; then
	#If the system has both s2idle and deep but s2idle is currently select, then deep sleep will be used
	#This will set mem_sleep_default=deep in grub - GRUB_CMDLINE_LINUX
	grubEnableDeepSleep=mem_sleep_default=deep
fi
if [ "$disableMitigations" = "y" ]; then
	#First check if grubOptionalSettings is empty. If it is not, add its contents to the overall boot options
	if [ -z "$grubEnableDeepSleep" ]; then
		grubCmdlineLinuxOptions="$grubSecurityMitigations $grubBootPerformance"
	else
		grubCmdlineLinuxOptions="$grubSecurityMitigations $grubBootPerformance $grubEnableDeepSleep"
	fi
fi


###GRUB CONFIG###
#Use CPU Random generation: https://security.stackexchange.com/questions/42164/rdrand-from-dev-random
#We most likely do not need anything more than mitigations=off, but having all these options (from https://make-linux-fast-again.com/) hurts nothing
#Generate grubcfg with root UUID if encrypt=y
if [ "$encrypt" = y ]; then
	uuid=$(lsblk -dno UUID "${storagePartitions[2]}")
	sed "s,\GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet\",\GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=$uuid:cryptroot root=/dev/mapper/cryptroot audit=0 loglevel=3\",g" -i /mnt/etc/default/grub
fi
#Generate grubcfg if no encryption
if [ "$encrypt" = n ]; then
	sed "s,\GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet\",\GRUB_CMDLINE_LINUX_DEFAULT=\"audit=0 loglevel=3\",g" -i /mnt/etc/default/grub
fi
#Append additional grub boot options if selected
if [ -z "$grubCmdlineLinuxOptions" ]; then
	#Do nothing if unset
	true
else
	#If set, add the options to grub
	sed "s,\GRUB_CMDLINE_LINUX=\"\",\GRUB_CMDLINE_LINUX=\"$grubCmdlineLinuxOptions\",g" -i /mnt/etc/default/grub
fi
#Change theme
echo 'GRUB_THEME="/boot/grub/themes/arch-silence/theme.txt"' >> /mnt/etc/default/grub
#Generate grubcfg
dialog --scrollbar --timeout 1 --backtitle "$dialogBacktitle" \
--title "Configuring grub" \
--prgbox "Generating grubcfg" "arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg" "$HEIGHT" "$WIDTH"
clear


###POST INSTALL###

#Unmount based on encryption
if [ "$encrypt" = y ]; then
	umount -R /mnt
	umount -R /mnt/boot
	cryptsetup close cryptroot
fi
if [ "$encrypt" = n ]; then
	umount -R /mnt
	umount -R /mnt/boot
fi
clear
echo "$green""Installation Complete. Thanks for installing!""$reset"
sleep 1s
exit 0
;;

done