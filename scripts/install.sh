#!/bin/bash

function print() {
    printf "\n<<< $1 >>>\n"
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

#dd if=/dev/zero of=/dev/sdX  bs=512  count=1
sgdisk --zap-all $INSTALLATION_DISK

if [[ $UEFI -eq 1 ]]; then
    printf "n\n1\n\n+512M\nef00\nw\ny\n" | gdisk /dev/sda
    yes | mkfs.vfat -F32 /dev/sda1
    printf "n\n2\n\n\n8e00\nw\ny\n"| gdisk /dev/sda
else
    printf "n\n p\n 1\n \n +512M\n w\n" | fdisk /dev/sda
    yes | mkfs.ext4 /dev/sda1
    printf "n\np\n2\n\n\nt\n2\n8e\nw\n" | fdisk /dev/sda
fi

