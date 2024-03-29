#!/bin/bash

source ./install.conf

sudo pacman -S xorg-server xorg-xinit --noconfirm --needed
sudo pacman -S $VIDEO_DRIVER --noconfirm --needed
sudo pacman -S deepin deepin-extra --noconfirm

sudo sed -z -i "s/\[Seat\:\*\]\n/\[Seat\:\*\]\ngreeter-session=lightdm-deepin-greeter\n/" /etc/lightdm/lightdm.conf

echo -e "$USER_PASSWORD\n" | sudo systemctl enable lightdm.service

print "Deepin desktop installation complete, type 'reboot' for Deepin login"
