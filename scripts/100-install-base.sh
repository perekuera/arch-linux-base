#!/bin/bash

function print() {
    printf "\n<<< $1 >>>\n"
}

#####################
### Configuration ###
#####################

INSTALLATION_DISK=/dev/sda
HOST_NAME=arch
TIME_ZONE=/usr/share/zoneinfo/Europe/Madrid
LOCALE_CONF=es_ES.UTF-8
KEYMAP=es
ROOT_PASSWORD=1234
USER_NAME=pere
USER_PASSWORD=1234

TEMP_PARTITION_DATA_FILE=/tmp/temp_partition_data_file.cfg

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

##############################
### Create disk partitions ###
##############################

print "Create partitions"

#dd if=/dev/zero of=/dev/sdX  bs=512  count=1
sgdisk --zap-all $INSTALLATION_DISK

if [[ $UEFI -eq 1 ]]; then
    #printf "n\n1\n\n+512M\nef00\nw\ny\n" | gdisk /dev/sda
    #yes | mkfs.vfat -F32 /dev/sda1
    #printf "n\nROOT_PASSWORD2\n\n\n8e00\nw\ny\n"| gdisk /dev/sda
    echo label: ROOT_PASSWORDgpt > $TEMP_PARTITION_DATA_FILE
    echo start=2ROOT_PASSWORD048,size=1048576,type=C12A7328-F81F-11D2-BA4B-00A0C93EC93B >> $TEMP_PARTITION_DATA_FILE
    echo type=0FROOT_PASSWORDC63DAF-8483-4772-8E79-3D69D8477DE4 >> $TEMP_PARTITION_DATA_FILE
elseROOT_PASSWORD
    #printf "n\nROOT_PASSWORD p\n 1\n \n +512M\n w\n" | fdisk /dev/sda
    #yes | mkfs.ROOT_PASSWORDext4 /dev/sda1
    #printf "n\nROOT_PASSWORDp\n2\n\n\nt\n2\n8e\nw\n" | fdisk /dev/sda
    echo label: ROOT_PASSWORDdos > $TEMP_PARTITION_DATA_FILE
    echo start=2048,type=83,bootable >> $TEMP_PARTITION_DATA_FILE
fi

sfdisk $INSTALLATION_DISK < $TEMP_PARTITION_DATA_FILE > /dev/nul

###############################
### Format/mount partitions ###
###############################

print "Format/mount partitions"

if [[ $UEFI -eq 1 ]]; then
    mkfs.vfat -F32 ${INSTALLATION_DISK}1
    mkfs.ext4 ${INSTALLATION_DISK}2
    mount ${INSTALLATION_DISK}2 /mnt
    mkdir -p /mnt/boot/efi
    mount ${INSTALLATION_DISK}1 /mnt/boot/efi
else
    mkfs.ext4 ${INSTALLATION_DISK}1
    mount ${INSTALLATION_DISK}1 /mnt
    mkdir /mnt/boot
fi

########################
### Install packages ###
########################

print "Install base packages"

pacstrap /mnt base base-devel grub

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

umount -R /mnt

#reboot
