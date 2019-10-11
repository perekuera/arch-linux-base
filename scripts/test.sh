#!/bin/bash

##########
# Config #
##########

# Instalation disk
DISK=sda

# Size in Mb
BOOT_PARTITION_SIZE=512
SWAP_PARTITION_SIZE=1024

##########
# Script #
##########

function test()
{
	echo start=512,size=$((BOOT_PARTITION_SIZE*2*1024)),type=83,bootable > /tmp/_partition_table.cfg
	if [ $SWAP_PARTITION_SIZE -gt 0 ]; then
		echo size=$((SWAP_PARTITION_SIZE*2*1024)),type=82 >> /tmp/_partition_table.cfg
	fi
	echo type=83 >> /tmp/_partition_table.cfg
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
