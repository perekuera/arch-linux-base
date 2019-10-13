#!/bin/bash

function create_partitions()
{
	echo "#################################"
	echo "## Create BIOS partition table ##"
	echo "#################################"
	sleep 1
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

function format_partitions() 
{
	echo "############################"
	echo "## Format BIOS partitions ##"
	echo "############################"
	sleep 1
	mkfs.ext2 -F $BOOT_PARTITION
	if [ "$SWAP_ON" = true ]; then
		mkswap $SWAP_PARTITION
	fi
	mkfs.ext4 -F $ROOT_PARTITION
	if [ "$HOME_ON" = true ]; then
		mkfs.ext4 -F $HOME_PARTITION
	fi
}

function mount_partitions()
{
	echo "###########################"
	echo "## Mount BIOS partitions ##"
	echo "###########################"
	sleep 1
	mount $ROOT_PARTITION /mnt
	mkdir /mnt/boot
	mount $BOOT_PARTITION /mnt/boot
	if [ "$HOME_ON" = true ]; then
		mkdir /mnt/home
		mount $HOME_PARTITION /mnt/home
	fi
	if [ "$SWAP_ON" = true ]; then
		swapon $SWAP_PARTITION
	fi
}

function grub_install()
{
	echo "##################"
	echo "## Grub install ##"
	echo "##################"
	sleep 1
	grub-install $DISK
	grub-mkconfig -o /boot/grub/grub.cfg
}
