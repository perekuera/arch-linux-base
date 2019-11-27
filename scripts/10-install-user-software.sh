#!/bin/bash

source ./install.conf

if [[ "$USER" != "$USER_NAME" ]]; then
    echo "Need login with user '$USER_NAME'"
    exit
fi

if [[ $ENABLE_WIFI -eq 1 ]]; then
    sudo nmcli dev wifi connect $WIFI_SSID password $WIFI_PASSWORD
fi

# installing refector to test wich servers are fastest
sudo pacman -S --noconfirm --needed reflector

# finding the fastest archlinux servers
sudo reflector -l 100 -f 50 --sort rate --threads 5 --verbose --save /tmp/mirrorlist.new && rankmirrors -n 0 /tmp/mirrorlist.new > /tmp/mirrorlist && sudo cp /tmp/mirrorlist /etc/pacman.d

sudo pacman -Syyu

if [[ $ENABLE_BLUETOOTH -eq 1 ]]; then
    sudo -S pacman -S bluez --noconfirm
    sudo -S systemctl enable bluetooth.service
fi

sudo -S pacman -S wget htop neofetch git --noconfirm

sudo echo -e "\nneofetch\n" >> ~/.bashrc

# install Packer
[ -d /tmp/packer ] && rm -rf /tmp/packer
mkdir /tmp/packer
wget https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=packer
mv PKGBUILD\?h\=packer /tmp/packer/PKGBUILD
cd /tmp/packer
makepkg -i /tmp/packer --noconfirm
[ -d /tmp/packer ] && rm -rf /tmp/packer

# install with Packer: yay
packer -Syu yay --noconfirm --noedit

print "User software installation complete"
