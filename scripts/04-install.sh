#!/bin/bash

source ./install.conf

function print() {
    printf "\n<<< $1 >>>\n"
    sleep 4
}

###########################
### Base configurations ###
###########################

print "Base configurations"

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
