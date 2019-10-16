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
#sgdisk --zap-all $INSTALLATION_DISK

UEFI=1

if [[ $UEFI -eq 1 ]]; then
    #printf "n\n1\n\n+512M\nef00\nw\ny\n" | gdisk /dev/sda
    #yes | mkfs.vfat -F32 /dev/sda1
    #printf "n\n2\n\n\n8e00\nw\ny\n"| gdisk /dev/sda
    echo label: gpt > $TEMP_PARTITION_DATA_FILE
    echo start=2048,size=1048576,type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B >> $TEMP_PARTITION_DATA_FILE
    echo type=0FC63DAF-8483-4772-8E79-3D69D8477DE4 >> $TEMP_PARTITION_DATA_FILE
else
    #printf "n\n p\n 1\n \n +512M\n w\n" | fdisk /dev/sda
    #yes | mkfs.ext4 /dev/sda1
    #printf "n\np\n2\n\n\nt\n2\n8e\nw\n" | fdisk /dev/sda
    echo label: dos > $TEMP_PARTITION_DATA_FILE
    echo start=2048,type=83,bootable >> $TEMP_PARTITION_DATA_FILE
fi

sfdisk $INSTALLATION_DISK < $TEMP_PARTITION_DATA_FILE > /dev/nul
