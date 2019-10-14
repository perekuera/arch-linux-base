#!/bin/bash

function install_base_packages()
{
	echo "###########################"
	echo "## Install base packages ##"
	echo "###########################"
	sleep 1
	#pacstrap /mnt base base-devel linux
    pacstrap /mnt base
    echo "Base packages install done"
}

function install_base_configurations()
{
	echo "#################################"
	echo "## Install base configurations ##"
	echo "#################################"
	sleep 1
	genfstab -pU /mnt >> /mnt/etc/fstab
    echo ">>> arch-chroot!!!!"
	arch-chroot /mnt /bin/bash <<EOF
        echo $HOST_NAME > /etc/hostname
        ln -sf $TIME_ZONE /etc/localtime
        sed -i "s/#${LOCALE_CONF}/${LOCALE_CONF}/g" /etc/locale.gen
        echo LANG=$LOCALE_CONF > /etc/locale.conf
        locale-gen
        hwclock -w
        echo KEYMAP=$KEYMAP > /etc/vconsole.conf
    EOF
}

function user_configurations()
{
    echo "Setting root password..."
    passwd
    if [ "$CREATE_USER" != "" ]; then
        useradd -m -g users -G audio,lp,optical,storage,video,wheel,games,power,scanner -s /bin/bash $CREATE_USER
        echo "Setting $CREATE_USER password..."
        passwd $CREATE_USER
    fi
}

function final_configurations()
{
    exit
    umount -R /mnt
    # reboot
}
