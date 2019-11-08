#!/bin/bash

source ./config.cfg

####################
### Grub install ###
####################

print "Grub install"

arch-chroot /mnt /bin/bash <<EOF
echo "Instal grub $INSTALLATION_DISK"
os-probes
grub-install $INSTALLATION_DISK
grub-mkconfig -o /boot/grub/grub.cfg
echo "Grub install done"
EOF

umount -R /mnt

print "Type 'reboot'"
