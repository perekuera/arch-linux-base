#!/bin/bash

source ./setup.conf
source ./src/auto-config.sh

# Create undo.sh
echo "umount -R /mnt" > undo.sh
if [ "$SWAP_ON" = true ]; then
	echo "	swapoff $SWAP_PARTITION" >> undo.sh
fi
echo "sfdisk --delete $DISK" >> undo.sh


