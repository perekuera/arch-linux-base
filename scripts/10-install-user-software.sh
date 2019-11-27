#!/bin/bash

source ./install.conf

if [[ "$USER" != "$USER_NAME" ]]; then
    echo "Need login with user '$USER_NAME'"
    exit
fi

if [[ $ENABLE_WIFI -eq 1 ]]; then
    echo -e "$USER_PASSWORD\n" | sudo nmcli dev wifi connect $WIFI_SSID password $WIFI_PASSWORD
fi

# installing refector to test wich servers are fastest
sudo pacman -S --noconfirm --needed reflector

# finding the fastest archlinux servers
sudo reflector -l 100 -f 50 --sort rate --threads 5 --verbose --save /tmp/mirrorlist.new && rankmirrors -n 0 /tmp/mirrorlist.new > /tmp/mirrorlist && sudo cp /tmp/mirrorlist /etc/pacman.d

sudo pacman -Syyu

if [[ $ENABLE_BLUETOOTH -eq 1 ]]; then
    echo -e "$USER_PASSWORD\n" | sudo -S pacman -S bluez --noconfirm
    echo -e "$USER_PASSWORD\n" | sudo -S systemctl enable bluetooth.service
fi

echo -e "$USER_PASSWORD\n" | sudo -S pacman -S wget htop neofetch git --noconfirm

echo -e "$USER_PASSWORD\n" | sudo echo -e "\nneofetch\n" >> .bashrc

# install packer (extra/install-packer.sh)
# install with packer: yay
