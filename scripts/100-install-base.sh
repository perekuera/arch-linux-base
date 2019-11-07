#!/bin/bash

function print() {
    printf "\n<<< $1 >>>\n"
}

#####################
### Configuration ###
#####################

INSTALLATION_DISK=/dev/sda

# Size in Mb (0 no swap)
SWAP_SIZE=1024

HOST_NAME=arch

TIME_ZONE=/usr/share/zoneinfo/Europe/Madrid

LOCALE_CONF=es_ES.UTF-8

KEYMAP=es

# Users
ROOT_PASSWORD=1234
USER_NAME=pere
USER_PASSWORD=1234

# Display configuration
print "Installation disk: $INSTALLATION_DISK"
if [[ $SWAP_SIZE -gt 0 ]]; then
    print "Swap partition size: ${SWAP_SIZE}Mb"
fi
print "Host name: $HOST_NAME"
print "Time zone: $TIME_ZONE"
print "Locale configuration: $LOCALE_CONF"
print "Keymap table: $KEYMAP"

sleep 3

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

sleep 1

##############################
### Create disk partitions ###
##############################

print "Create partitions"

TEMP_PARTITION_DATA_FILE=/tmp/temp_partition_data_file.cfg

sgdisk --zap-all $INSTALLATION_DISK

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
        echo start=2048,type=82 >> $TEMP_PARTITION_DATA_FILE
        echo type=83,bootable >> $TEMP_PARTITION_DATA_FILE
    else
        echo start=2048,type=83,bootable >> $TEMP_PARTITION_DATA_FILE
    fi
fi

sfdisk $INSTALLATION_DISK < $TEMP_PARTITION_DATA_FILE > /dev/nul

sleep 3

###############################
### Format/mount partitions ###
###############################

print "Format/mount partitions"

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

sleep 3

exit

########################
### Install packages ###
########################

print "Install base packages"

pacstrap /mnt base base-devel linux linux-firmware networkmanager grub nano

sleep 1

###########################
### Base configurations ###
###########################

print "Base configurations"

genfstab -pU /mnt >> /mnt/etc/fstab
arch-chroot /mnt /bin/bash <<EOF
echo $HOST_NAME > /etc/hostname
ln -sf $TIME_ZONE /etc/localtime
sed -i "s/#${LOCALE_CONF}/${LOCALE_CONF}/g" /etc/locale.gen
echo LANG=$LOCALE_CONF > /etc/locale.conf
locale-gen
hwclock -w
echo KEYMAP=$KEYMAP > /etc/vconsole.conf
mkinitcpio -p linux
systemctl enable NetworkManager
EOF

#############
### Users ###
#############

print "Users"

arch-chroot /mnt /bin/bash <<EOF
echo "root:${ROOT_PASSWORD}" | chpasswd
useradd -m -g users -G audio,lp,optical,storage,video,wheel,games,power,scanner -s /bin/bash $USER_NAME
echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd
EOF

sleep 3

####################
### Grub install ###
####################

print "Grub install"

arch-chroot /mnt /bin/bash <<EOF
echo "Instal grub $INSTALLATION_DISK"
grub-install --target=i386-pc --recheck $INSTALLATION_DISK
grub-mkconfig -o /boot/grub/grub.cfg
echo "Grub install done"
EOF

umount -R /mnt

print "Rebooting system"

sleep 3

reboot
