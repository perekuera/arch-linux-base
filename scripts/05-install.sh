#!/bin/bash

source ./install.conf

function print() {
    printf "\n<<< $1 >>>\n"
    sleep 4
}

#############
### Users ###
#############

print "Create root and default user"

arch-chroot /mnt /bin/bash <<EOF
echo "root:${ROOT_PASSWORD}" | chpasswd
useradd -m -g users -G audio,lp,optical,storage,video,wheel,games,power,scanner,network,rfkill -s /bin/bash $USER_NAME
echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd
sed -r -i "s/# %wheel ALL=\(ALL\) ALL/%wheel ALL=\(ALL\) ALL/g" /etc/sudoers
EOF
