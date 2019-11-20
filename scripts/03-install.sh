#!/bin/bash

source ./install.conf

UEFI=1

function print() {
    printf "\n<<< $1 >>>\n"
    sleep 4
}

########################
### Install packages ###
########################

print "Install base packages"

pacstrap /mnt base base-devel linux linux-firmware \
              os-prober networkmanager grub bash-completion \
              nano ntfs-3g gvfs gvfs-afc gvfs-mtp xdg-user-dirs

if [[ $UEFI -eq 1 ]]; then
    pacstrap /mnt efibootmgr
fi

if [[ $ENABLE_WIFI -eq 1 ]]; then
    pacstrap /mnt netctl wpa_supplicant dialog
fi

if [[ $ENABLE_TOUCHPAD -eq 1 ]]; then
    pacstrap /mnt xf86-input-synaptics
fi

genfstab -U /mnt >> /mnt/etc/fstab
