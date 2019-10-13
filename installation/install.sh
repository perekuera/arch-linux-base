#!/bin/bash

source ./setup.conf
source ./src/auto-config.sh

if [ $EFI_MODE = true ]; then
	source ./src/efi-system.sh
else
	source ./src/bios-system.sh
fi

source ./src/base-installation.sh

# Create undo.sh
echo "umount -R /mnt" > undo.sh
if [ "$SWAP_ON" = true ]; then
	echo "	swapoff $SWAP_PARTITION" >> undo.sh
fi
echo "sfdisk --delete $DISK" >> undo.sh

create_partitions
format_partitions
mount_partitions

install_base_packages
install_base_configurations

exit 0
