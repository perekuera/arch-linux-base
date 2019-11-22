#!/bin/bash

source ./install.conf

sudo pacman -S xorg-server xorg-apps xorg-xinit xorg-twm xterm --noconfirm --needed
sudo pacman -S $VIDEO_DRIVER --noconfirm --needed
sudo pacman -S cinnamon --noconfirm
sudo pacman -S lightdm lightdm-gtk-greeter --noconfirm

sudo systemctl enable lightdm.service

echo "rebooting..."

sleep 3

#reboot
