#!/bin/bash

source ./install.conf

if [[ "$USER" != "$USER_NAME" ]]; then
    echo "Need login with user '$USER_NAME'"
    exit
fi

# Google Chrome
yay -S google-chrome

# Firefox
sudo pacman -S firefox --noconfirm --needed

sudo pacman -S vi vim zsh file-roller grub-customizer --noconfirm --needed

#spotify
cd ~
gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 2EBF997C15BDA244B6EBF5D84773BD5E130D1D45
git clone https://aur.archlinux.org/spotify.git
cd spotify
makepkg -sri --noconfirm
rm -rf ~/spotify
