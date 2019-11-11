#!/bin/bash

source ./install.conf

function print() {
    printf "\n<<< $1 >>>\n"
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
sleep 3

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

###############################
### Format/mount partitions ###
###############################

print "Format/mount partitions"
sleep 3

if [[ $UEFI -eq 1 ]]; then
    mkfs.vfat -F32 ${INSTALLATION_DISK}1
    if [[ $SWAP_SIZE -gt 0 ]]; then
        mkswap ${INSTALLATION_DISK}2
        swapon ${INSTALLATION_DISK}2
        mkfs.ext4 ${INSTALLATION_DISK}3
        mount ${INSTALLATION_DISK}3 /mnt
    else
        mkfs.ext4 ${INSTALLATION_DISK}2
        mount ${INSTALLATION_DISK}2 /mnt
    fi
    mkdir -p /mnt/boot/efi
    mount ${INSTALLATION_DISK}1 /mnt/boot/efi
else
    if [[ $SWAP_SIZE -gt 0 ]]; then
        mkswap ${INSTALLATION_DISK}1
        swapon ${INSTALLATION_DISK}1
        mkfs.ext4 ${INSTALLATION_DISK}2
        mount ${INSTALLATION_DISK}2 /mnt
    else
        mkfs.ext4 ${INSTALLATION_DISK}1
        mount ${INSTALLATION_DISK}1 /mnt
    fi
    mkdir /mnt/boot
fi

genfstab -U /mnt >> /mnt/etc/fstab

########################
### Install packages ###
########################

print "Install base packages"
sleep 3

pacstrap /mnt base base-devel linux linux-firmware 
pacstrap /mnt os-prober networkmanager grub bash-completion 
pacstrap /mnt nano ntfs-3g gvfs gvfs-afc gvfs-mtp xdg-user-dirs

if [[ $UEFI -eq 1 ]]; then
    pacstrap /mnt efibootmgr
fi

if [[ $ENABLE_WIFI -eq 1 ]]; then
    pacstrap /mnt netctl wpa_supplicant dialog
fi

if [[ $ENABLE_TOUCHPAD -eq 1 ]]; then
    pacstrap /mnt xf86-input-synaptics
fi


###########################
### Base configurations ###
###########################

print "Base configurations"
sleep 3

arch-chroot /mnt /bin/bash <<EOF
ln -sf $TIME_ZONE /etc/localtime
hwclock --systohc
echo $HOST_NAME > /etc/hostname
echo -e "127.0.0.1\tlocalhost" >> /etc/hosts
echo -e "::1\t\tlocalhost" >> /etc/hosts
echo -e "127.0.0.1\t${HOST_NAME}.localdomain\t${HOST_NAME}" >> /etc/hosts
echo LANG=$LOCALE_CONF > /etc/locale.conf
echo KEYMAP=$KEYMAP > /etc/vconsole.conf
sed -i "s/#${LOCALE_CONF}/${LOCALE_CONF}/" /etc/locale.gen
locale-gen
sed -z -i "s/#\[multilib\]\n#Include/\[multilib\]\nInclude/" /etc/pacman.conf
mkinitcpio -p linux
systemctl enable NetworkManager
EOF

if [[ ! -z "$WIFI_SSID" && ! -z "$WIFI_PASSWORD" ]]; then
arch-chroot /mnt /bin/bash <<EOF
nmcli dev wifi connect $WIFI_SSID password $WIFI_PASSWORD
EOF
fi

#############
### Users ###
#############

print "Create root and default user"
sleep 3

arch-chroot /mnt /bin/bash <<EOF
echo "root:${ROOT_PASSWORD}" | chpasswd
useradd -m -g users -G audio,lp,optical,storage,video,wheel,games,power,scanner,network,rfkill -s /bin/bash $USER_NAME
echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd
sed -r -i "s/# %wheel ALL=\(ALL\) ALL/%wheel ALL=\(ALL\) ALL/g" /etc/sudoers
EOF

####################
### Grub install ###
####################

print "Grub install"
sleep 3

arch-chroot /mnt /bin/bash <<EOF
echo "Instal grub $INSTALLATION_DISK"
os-probes
grub-install $INSTALLATION_DISK
grub-mkconfig -o /boot/grub/grub.cfg
echo "Grub install done"
EOF

print "Update packages"
sleep 3

arch-chroot /mnt /bin/bash <<EOF
pacman -Syyu
EOF

umount -R /mnt

print "Base installation complete, type 'reboot'"
