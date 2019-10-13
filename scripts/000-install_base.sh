#!/bin/bash

############
## Script ##
############


if [ "$EFI_MODE" = true ]; then
	echo ""
#	create_partition_efi
#	format_partition_efi
#	mount_partition_efi
else
	create_partition_bios
	format_partition_bios
	mount_partition_bios
fi

install_base_packages
install_base_configurations

create_undo_all

exit 0
