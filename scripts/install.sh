#!/bin/bash

source ./setup.conf

echo "Installation disk $DISK"

efivar -l >/dev/null 2>&1

if [[ $? -eq 0 ]]; then
    UEFI=1
    echo "UEFI detected"
else
    UEFI=0
    echo "BIOS detected"
fi
