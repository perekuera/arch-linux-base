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

##########
# Script #
##########

function test()
{
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
}

function create_partition_efi() 
{
	echo Create EFI partition table...
}

function create_partition_bios()
{
	echo Create BIOS partition table...
	{
	test
	sfdisk /dev/$DISK < $PARTITION_DATA_FILE
	sfdisk -d /dev/$DISK
	exit 0
	sfdisk /dev/$DISK <<EOF
start=512,size=$((BOOT_PARTITION_SIZE*2*1024)),type=83,bootable
size=$((SWAP_PARTITION_SIZE*2*1024)),type=82
type=83
EOF
	} > /dev/nul
	sfdisk -d /dev/$DISK
}

ls /sys/firmware/efi/efivars &> /dev/nul
if [ $? -eq 0 ]; then
	echo EFI mode ON
	create_partition_efi
else
	echo EFI mode OFF
	create_partition_bios
fi

exit 0
