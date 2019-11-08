#!/bin/bash

soruce ./config.cfg

########################
### Install packages ###
########################

function print() {
    printf "\n<<< $1 >>>\n"
}

print "Install base packages"

pacstrap /mnt base base-devel linux linux-firmware 
pacstrap /mnt os-prober networkmanager grub bash-completion nano
