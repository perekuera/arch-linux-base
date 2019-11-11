#!/bin/bash

sudo pacman -S cinnamon --noconfirm

sudo pacman -S lightdm lightdm-gtk-greeter

sudo systemctl enable lightdm.service

echo "rebooting..."

sleep 3

reboot
