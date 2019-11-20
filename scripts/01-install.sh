#!/bin/bash

source ./install.conf

function print() {
    printf "\n<<< $1 >>>\n"
    sleep 4
}

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

##############################
### Create disk partitions ###
##############################

print "Create partitions"

TEMP_PARTITION_DATA_FILE=/tmp/temp_partition_data_file.cfg

#sgdisk --zap-all $INSTALLATION_DISK
wipefs --all $INSTALLATION_DISK > /dev/null

if [[ $UEFI -eq 1 ]]; then
    echo label: gpt > $TEMP_PARTITION_DATA_FILE
    echo start=2048,size=1048576,type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B >> $TEMP_PARTITION_DATA_FILE
    if [[ $SWAP_SIZE -gt 0 ]]; then
        echo size=$(($SWAP_SIZE * 2048)),type=0657FD6D-A4AB-43C4-84E5-0933C84B4F4F >> $TEMP_PARTITION_DATA_FILE
    fi
    echo type=0FC63DAF-8483-4772-8E79-3D69D8477DE4 >> $TEMP_PARTITION_DATA_FILE
else
    echo label: dos > $TEMP_PARTITION_DATA_FILE
    if [[ $SWAP_SIZE -gt 0 ]]; then
        echo start=2048,size=$(($SWAP_SIZE * 2048)),type=82 >> $TEMP_PARTITION_DATA_FILE
        print "Swap partition created"
        echo type=83,bootable >> $TEMP_PARTITION_DATA_FILE
    else
        echo start=2048,type=83,bootable >> $TEMP_PARTITION_DATA_FILE
    fi
fi

sfdisk --force $INSTALLATION_DISK < $TEMP_PARTITION_DATA_FILE > /dev/null
