# Autoconfig variables

function error()
{
	echo "$1" 1>&2
	exit 1
}

SWAP_ON=false
HOME_ON=false

PN=0

if [ $SWAP_PARTITION_SIZE -gt 0 ]; then
	PN=`expr $PN + 1`
	BOOT_PARTITION=${DISK}${PN}
else
	error "Boot partition size required..."
fi

if [ $SWAP_PARTITION_SIZE -gt 0 ]; then
	PN=`expr $PN + 1`
	SWAP_ON=true
	SWAP_PARTITION=${DISK}${PN}
fi

if [ $ROOT_PARTITION_SIZE -gt 0 ] || [ $ROOT_PARTITION_SIZE -eq -1 ]; then
	PN=`expr $PN + 1`
	ROOT_PARTITION=${DISK}${PN}
else
	error "Root partition size required..."
fi

if [ $ROOT_PARTITION_SIZE -ne -1 ]; then
	if [ $HOME_PARTITION_SIZE -gt 0 ] || [ $HOME_PARTITION_SIZE -eq -1 ]; then
		PN=`expr $PN + 1`
		HOME_ON=true
		HOME_PARTITION=${DISK}${PN}
	else
		error "Home partition size required..."
	fi
fi

EFI_MODE=false

ls /sys/firmware/efi/efivars &> /dev/nul
if [ $? -eq 0 ]; then
	EFI_MODE=true
fi

echo "Boot partition = $BOOT_PARTITION - $BOOT_PARTITION_SIZE" 
echo "Swap partition = ($SWAP_ON) $SWAP_PARTITION - $SWAP_PARTITION_SIZE"
echo "Root partition = $ROOT_PARTITION - $ROOT_PARTITION_SIZE"
echo "Home partition = ($HOME_ON) $HOME_PARTITION - $HOME_PARTITION_SIZE"
