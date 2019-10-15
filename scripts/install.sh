#!/bin/bash

function print() {
    printf "<<<\n\t$1\n>>>"
}

source ./setup.conf

# Display configuration
print "Installation disk: $INSTALLATION_DISK"

sleep 1

###########################
### UEFI/BIOS detection ###
###########################

efivar -l >/dev/null 2>&1

if [[ $? -eq 0 ]]; then
    UEFI=1
    print "UEFI detected"
else
    UEFI=0
    print "BIOS detected"
fi

#######################
### Disk partitions ###
#######################

sgdisk --zap-all $INSTALLATION_DISK

if [[ $UEFI -eq 1 ]]; then
    printf "n\n1\n\n+512M\nef00\nw\ny\n" | gdisk /dev/sda
    yes | mkfs.vfat -F32 /dev/sda1
else
    printf "n\np\n1\n\n+512M\nw\n" | fdisk /dev/sda
    yes | mkfs.ext4 /dev/sda1
fi

