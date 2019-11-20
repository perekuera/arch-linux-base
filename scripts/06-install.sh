#!/bin/bash

source ./install.conf

function print() {
    printf "\n<<< $1 >>>\n"
    sleep 4
}

####################
### Grub install ###
####################

print "Grub install"

arch-chroot /mnt /bin/bash <<EOF
echo "Install grub $INSTALLATION_DISK"
os-prober
grub-install $INSTALLATION_DISK
grub-mkconfig -o /boot/grub/grub.cfg
echo "Grub install done"
EOF
