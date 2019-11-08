#!/bin/bash

soruce ./config.cfg

#############
### Users ###
#############

print "Users"

arch-chroot /mnt /bin/bash <<EOF
echo "root:${ROOT_PASSWORD}" | chpasswd
useradd -m -g users -G audio,lp,optical,storage,video,wheel,games,power,scanner,network,rfkill -s /bin/bash $USER_NAME
echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd
sed -r -i "s/# %wheel ALL=\(ALL\) ALL/%wheel ALL=\(ALL\) ALL/g" /etc/sudoers
EOF
