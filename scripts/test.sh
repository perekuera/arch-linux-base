#!/bin/bash

##########
# Config #
##########

# Instalation disk
DISK=sda
PARTITION_DATA_FILE=/tmp/partition_data.cfg

# Size in Mb
BOOT_PARTITION_SIZE=512
SWAP_PARTITION_SIZE=0
ROOT_SIZE=8192

#read -p "Enter number" INPUT

##########
# Script #
##########

function create_partition_efi() 
{
	echo Create EFI partition table...
}

function format_partition_efi()
{

}

function create_partition_bios()
{
	echo Create BIOS partition table...
	echo start=512,size=$((BOOT_PARTITION_SIZE*2*1024)),type=83,bootable > $PARTITION_DATA_FILE
	if [ $SWAP_PARTITION_SIZE -gt 0 ]; then
		echo size=$((SWAP_PARTITION_SIZE*2*1024)),type=82 >> $PARTITION_DATA_FILE
	fi
	if [ $ROOT_SIZE -eq 0 ]; then
		# all for /
		echo type=83 >> $PARTITION_DATA_FILE
	else
		echo size=$((ROOT_SIZE*2*1024)),type=83 >> $PARTITION_DATA_FILE
		# rest for /home
		echo type=83 >> $PARTITION_DATA_FILE
	fi
	sfdisk /dev/$DISK < $PARTITION_DATA_FILE > /dev/nul
	sfdisk -d /dev/$DISK
}

function format_partition_bios() 
{
	PN=0
	echo Formating partitions...
	PN=`expr $PN + 1`
	echo mkfs.ext2 /dev/${DISK}${PN}
	if [ $SWAP_PARTITION_SIZE -gt 0 ]; then
		PN=`expr $PN + 1`
		echo mkswap /dev/${DISK}${PN}
	fi
	PN=`expr $PN + 1`
	echo mkfs.ext4 /dev/${DISK}${PN}
	if [ $ROOT_SIZE -ne 0 ]; then
		PN=`expr $PN + 1`
		echo mkfs.ext4 /dev/${DISK}${PN}
	fi
}

ls /sys/firmware/efi/efivars &> /dev/nul
if [ $? -eq 0 ]; then
	echo EFI mode ON
	create_partition_efi
	format_partition_efi
else
	echo EFI mode OFF
	create_partition_bios
	format_partition_bios
fi

exit 0
