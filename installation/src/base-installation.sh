#!/bin/bash

function install_base_packages()
{
	echo "###########################"
	echo "## Install base packages ##"
	echo "###########################"
	sleep 1
	#pacstrap /mnt base base-devel linux grub
    pacstrap /mnt base grub
    echo "Base packages install done"
}

function install_base_configurations()
{
	echo "#################################"
	echo "## Install base configurations ##"
	echo "#################################"
	sleep 1
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
    echo "Base configurations install done"
}

function user_configurations()
{
	echo "#########################"
	echo "## User configurations ##"
	echo "#########################"
    arch-chroot /mnt /bin/bash <<EOF
        echo "root:${ROOT_PASSWORD}" | chpasswd
EOF
    if [ "$USERNAME" != "" ]; then
        arch-chroot /mnt /bin/bash <<EOF
            useradd -m -g users -G audio,lp,optical,storage,video,wheel,games,power,scanner -s /bin/bash $USER_NAME
            echo "Setting $USER_NAME password..."
            echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd
EOF
    fi
    echo "User configurations done"
}

function final_configurations()
{
	echo "##########################"
	echo "## Final configurations ##"
	echo "##########################"
    umount -R /mnt
    # reboot
    echo "Final configurations done"
}
