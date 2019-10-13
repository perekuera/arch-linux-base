function install_base_packages()
{
	echo "###########################"
	echo "## Install base packages ##"
	echo "###########################"
	sleep 1
	pacstrap /mnt base base-devel linux
}

function install_base_configurations()
{
	echo "#################################"
	echo "## Install base configurations ##"
	echo "#################################"
	sleep 1
	genfstab -pU /mnt >> /mnt/etc/fstab
	arch-chroot /mnt
	echo $HOST_NAME > /etc/hostname
	ln -sf $TIME_ZONE /etc/localtime
	sed -i "s/#${LOCALE_CONF}/${LOCALE_CONF}/g" /etc/locale.gen
}
