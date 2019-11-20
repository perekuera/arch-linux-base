#!/bin/bash

source ./install.conf

UEFI=1

function print() {
    printf "\n<<< $1 >>>\n"
    sleep 4
}

####################
### Grub install ###
####################

print "Grub install"

if [[ $UEFI -eq 1 ]]; then
arch-chroot /mnt /bin/bash <<EOF
echo "Install grub-efi $INSTALLATION_DISK"
grub-install --efi-directory=/boot/efi --bootloader-id='Arch Linux' --target=x86_64-efi
os-prober
grub-mkconfig -o /boot/grub/grub.cfg
echo "Grub install done"
EOF
else
arch-chroot /mnt /bin/bash <<EOF
echo "Install grub-bios $INSTALLATION_DISK"
grub-install $INSTALLATION_DISK
os-prober
grub-mkconfig -o /boot/grub/grub.cfg
echo "Grub install done"
EOF
fi
