#!/bin/bash

source ./install.conf

UEFI=1

function print() {
    printf "\n<<< $1 >>>\n"
    sleep 4
}

###############################
### Format/mount partitions ###
###############################

print "Format/mount partitions"

if [[ $UEFI -eq 1 ]]; then
    mkfs.vfat -F32 ${INSTALLATION_DISK}1
    if [[ $SWAP_SIZE -gt 0 ]]; then
        mkswap ${INSTALLATION_DISK}2
        swapon ${INSTALLATION_DISK}2
        mkfs.ext4 -F ${INSTALLATION_DISK}3
        mount ${INSTALLATION_DISK}3 /mnt
    else
        mkfs.ext4 -F ${INSTALLATION_DISK}2
        mount ${INSTALLATION_DISK}2 /mnt
    fi
    mkdir -p /mnt/boot/efi
    mount ${INSTALLATION_DISK}1 /mnt/boot/efi
else
    if [[ $SWAP_SIZE -gt 0 ]]; then
        mkswap ${INSTALLATION_DISK}1
        swapon ${INSTALLATION_DISK}1
        mkfs.ext4 -F ${INSTALLATION_DISK}2
        mount ${INSTALLATION_DISK}2 /mnt
    else
        mkfs.ext4 -F ${INSTALLATION_DISK}1
        mount ${INSTALLATION_DISK}1 /mnt
    fi
    mkdir /mnt/boot
fi
