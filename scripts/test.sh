#!/bin/bash

############
## Config ##
############

# Instalation disk
DISK=/dev/sda
PARTITION_DATA_FILE=/tmp/partition_data.cfg

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

echo Boot partition = $BOOT_PARTITION
if [ "$SWAP_ON" = true ]; then
	echo Swap partition = $SWAP_PARTITION
fi
echo Root partition = $ROOT_PARTITION
if [ "$HOME_ON" = true ]; then
	echo Home partition = $HOME_PARTITION
fi

exit 0

############
## Script ##
############

function create_partition_efi() 
{
	echo ################################
	echo ## Create EFI partition table ##
	echo ################################
}

function format_partition_efi()
{
	echo ###########################
	echo ## Format EFI partitions ##
	echo ###########################
}

function mount_partition_efi()
{
	echo ##########################
	echo ## Mount EFI partitions ##
	echo ##########################
}

function create_partition_bios()
{
	echo #################################
	echo ## Create BIOS partition table ##
	echo #################################
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
	echo ############################
	echo ## Format BIOS partitions ##
	echo ############################
	mkfs.ext2 $BOOT_PARTITION
	if [ "$SWAP_ON" = true ]; then
		mkswap $SWAP_PARTITION
		swapon $SWAP_PARTITION
	fi
	mkfs.ext4 $ROOT_PARTITION
	if [ "$HOME_ON" = true ]; then
		mkfs.ext4 $HOME_PARTITION
	fi
}

function mount_partition_bios()
{
	echo ###########################
	echo ## Mount BIOS partitions ##
	echo ###########################
}

ls /sys/firmware/efi/efivars &> /dev/nul
if [ $? -eq 0 ]; then
	echo EFI mode ON
	create_partition_efi
	format_partition_efi
	mount_partition_efi
else
	echo EFI mode OFF
	create_partition_bios
	format_partition_bios
	mount_partition_bios
fi

exit 0
