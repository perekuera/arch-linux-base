#!/bin/bash

source ./install.conf

function print() {
    printf "\n<<< $1 >>>\n"
    sleep 4
}

arch-chroot /mnt /bin/bash <<EOF
pacman -Syyu
pacman -S git --noconfirm
EOF

umount -R /mnt

print "Base installation complete, type 'reboot'"
