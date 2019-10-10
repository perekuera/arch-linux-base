#!/bin/bash

# Configurations
DISK=sda


# Script

function create_partition_efi() 
{
	echo Create EFI partition table...
}

function create_partition_bios()
{
	echo Create no EFI partition table...
	sfdisk /dev/$DISK <<EOF
start=512,size=1048576,type=83,bootable
size=2097152,type=82
type=83
EOF
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
