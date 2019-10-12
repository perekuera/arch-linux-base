#!/bin/bash

############
## Config ##
############

# Instalation disk
DISK=/dev/sda
PARTITION_DATA_FILE=/tmp/partition_data.cfg

HOST_NAME=arch
TIME_ZONE=/usr/share/zoneinfo/Europe/Madrid

# Size in Mb (0 for no partition)
BOOT_PARTITION_SIZE=512
SWAP_PARTITION_SIZE=512
ROOT_PARTITION_SIZE=8192

#read -p "Enter number" INPUT

# Autoconfig variables
SWAP_ON=false
HOME_ON=false

PN=0
PN=`expr $PN + 1`
BOOT_PARTITION=${DISK}${PN}
if [ $SWAP_PARTITION_SIZE -gt 0 ]; then
	PN=`expr $PN + 1`
	SWAP_ON=true
	SWAP_PARTITION=${DISK}${PN}
fi
PN=`expr $PN + 1`
ROOT_PARTITION=${DISK}${PN}
if [ $ROOT_PARTITION_SIZE -ne 0 ]; then
	PN=`expr $PN + 1`
	HOME_ON=true
	HOME_PARTITION=${DISK}${PN}
fi

############
## Script ##
############

function create_partition_efi() 
{
	echo "################################"
	echo "## Create EFI partition table ##"
	echo "################################"
	sleep 1
}

function format_partition_efi()
{
	echo "###########################"
	echo "## Format EFI partitions ##"
	echo "###########################"
	sleep 1
}

function mount_partition_efi()
{
	echo "##########################"
	echo "## Mount EFI partitions ##"
	echo "##########################"
	sleep 1
}

function create_partition_bios()
{
	echo "#################################"
	echo "## Create BIOS partition table ##"
	echo "#################################"
	sleep 1
	echo start=512,size=$((BOOT_PARTITION_SIZE*2*1024)),type=83,bootable > $PARTITION_DATA_FILE
	if [ "$SWAP_ON" = true ]; then
		echo size=$((SWAP_PARTITION_SIZE*2*1024)),type=82 >> $PARTITION_DATA_FILE
	fi
	if [ "$HOME_ON" = false ]; then
		# all for /
		echo type=83 >> $PARTITION_DATA_FILE
	else
		echo size=$((ROOT_PARTITION_SIZE*2*1024)),type=83 >> $PARTITION_DATA_FILE
		# rest for /home
		echo type=83 >> $PARTITION_DATA_FILE
	fi
	sfdisk $DISK < $PARTITION_DATA_FILE > /dev/nul
	sfdisk -d $DISK
}

function format_partition_bios() 
{
	echo "############################"
	echo "## Format BIOS partitions ##"
	echo "############################"
	sleep 1
	mkfs.ext2 -F $BOOT_PARTITION
	if [ "$SWAP_ON" = true ]; then
		mkswap $SWAP_PARTITION
	fi
	mkfs.ext4 -F $ROOT_PARTITION
	if [ "$HOME_ON" = true ]; then
		mkfs.ext4 -F $HOME_PARTITION
	fi
}

function mount_partition_bios()
{
	echo "###########################"
	echo "## Mount BIOS partitions ##"
	echo "###########################"
	sleep 1
	mount $ROOT_PARTITION /mnt
	mkdir /mnt/boot
	mount $BOOT_PARTITION /mnt/boot
	if [ "$HOME_ON" = true ]; then
		mkdir /mnt/home
		mount $HOME_PARTITION /mnt/home
	fi
	if [ "$SWAP_ON" = true ]; then
		swapon $SWAP_PARTITION
	fi
}

function install_base_packages()
{
	echo "###########################"
	echo "## Install base packages ##"
	echo "###########################"
	sleep 1
	pacstrap /mnt base base-devel linux
}

function install_base_configurations()
{
	echo "#################################"
	echo "## Install base configurations ##"
	echo "#################################"
	sleep 1
	genfstab -pU /mnt >> /mnt/etc/fstab
	arch-chroot /mnt
	echo $HOST_NAME > /etc/hostname
	ln -sf $TIME_ZONE /etc/localtime
	
}

function create_undo_all() 
{
	echo "umount -R /mnt" > undo.sh
	if [ "$SWAP_ON" = true ]; then
		echo "	swapoff $SWAP_PARTITION" >> undo.sh
	fi
	echo "sfdisk --delete $DISK" >> undo.sh
}

EFI_MODE=false

ls /sys/firmware/efi/efivars &> /dev/nul
if [ $? -eq 0 ]; then
	EFI_MODE=true
fi

if [ "$EFI_MODE" = true ]; then
	create_partition_efi
	format_partition_efi
	mount_partition_efi
else
	create_partition_bios
	format_partition_bios
	mount_partition_bios
fi

install_base_packages
install_base_configurations

create_undo_all

exit 0
