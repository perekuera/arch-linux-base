#!/bin/bash

sudo pacman -S xorg-server xorg-apps xorg-xinit xorg-twm xterm --noconfirm --needed
sudo pacman -S mesa mesa-demos --noconfirm --needed

sudo pacman -S xf86-video-intel intel-ucode --noconfirm --needed
