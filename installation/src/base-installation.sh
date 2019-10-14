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
    echo ">>> getfstab!!!!"
	genfstab -pU /mnt >> /mnt/etc/fstab
    echo ">>> arch-chroot!!!!"
	arch-chroot /mnt
    echo ">>> host name!!!!"
	echo $HOST_NAME > /etc/hostname
    echo ">>> local time!!!!"
	ln -sf $TIME_ZONE /etc/localtime
    echo ">>> locale gen!!!!"
	sed -i "s/#${LOCALE_CONF}/${LOCALE_CONF}/g" /etc/locale.gen
    echo ">>> locale conf!!!!"
    echo LANG=$LOCALE_CONF > /etc/locale.conf
    echo ">>> locale gen!!!!"
    locale-gen
    echo ">>> clock!!!!"
    hwclock -w
    echo ">>>> vconsole!!!!"
    echo KEYMAP=$KEYMAP > /etc/vconsole.conf
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
