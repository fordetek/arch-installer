#!/bin/sh
set -e
set -u

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

installAURPackages()
{
	# Change sudoers to allow wheel group access to sudo without password
	sed -i 's/%wheel ALL=(ALL) ALL/# %wheel ALL=(ALL) ALL/' /etc/sudoers
	sed -i 's/# %wheel ALL=(ALL) NOPASSWD/%wheel ALL=(ALL) NOPASSWD/' /etc/sudoers
	
	# Add nobody user to wheel group
	gpasswd -a nobody wheel
	
	# Install AUR Packages
	sudo -u nobody packer -S --noconfirm $@
	
	# Remove nobody user from wheel group
	gpasswd -d nobody wheel
	
	# Change sudoers to allow wheel group access to sudo with password
	sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
	sed -i 's/%wheel ALL=(ALL) NOPASSWD/# %wheel ALL=(ALL) NOPASSWD/' /etc/sudoers
}

##############################
## Installation of Packages ##
##############################

# Install Packages
pacman -Sy --noconfirm --needed kodi

# Install Optional Dependencies
pacman -Sy --noconfirm --needed --asdeps libnfs libplist shairplay lirc udisks unrar unzip lsb-release

# Download and Install AUR Packages
installAURPackages kodi-standalone-service kodi-addon-pvr-hts-git

# Core Packages
# kodi						= Kodi Media Center					= https://www.archlinux.org/packages/community/x86_64/kodi/

# Kodi Optional Dependencies
# libnfs 					= NFS shares support				= https://www.archlinux.org/packages/community/x86_64/libnfs/
# libplist					= AirPlay support					= https://www.archlinux.org/packages/extra/x86_64/libplist/
# shairplay					= AirPlay support					= https://www.archlinux.org/packages/community/x86_64/shairplay/
# lirc						= Linux IR Control					= https://www.archlinux.org/packages/extra/x86_64/lirc/
# udisks					= Automount external drives			= https://www.archlinux.org/packages/extra/x86_64/udisks/
# unrar						= Unrar Archives support			= https://www.archlinux.org/packages/extra/x86_64/unrar/
# unzip						= Winzip Archives support 			= https://www.archlinux.org/packages/extra/x86_64/unzip/
# lsb-release				= Log distro info in crashlog		= https://www.archlinux.org/packages/community/any/lsb-release/

# AUR Packages
# kodi-standalone-service	= Allow Direct booting				= https://aur.archlinux.org/packages/kodi-standalone-service/
# kodi-addon-pvr-hts-git	= TVHeadend PVR Support				= https://aur.archlinux.org/packages/kodi-addon-pvr-hts-git/


#############
## General ##
#############

# Enable systemd-timesyncd service
timedatectl set-ntp true

############
## Extras ##
############

# Enable and start kodi
systemctl enable kodi
systemctl start kodi