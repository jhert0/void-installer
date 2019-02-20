#!/bin/bash

DISK=$1
USR=$2

HOSTNAME="localhost"
TIMEZONE="America/Chicago"

source shared.sh

chown root:root /
chmod 755 /

interfaces=$(ip -o link show | awk -F': ' '{print $2}')
PS3="Please select the correct network device: "
select interface in $interfaces; do
    if contains_element $interface; then
        yes_no_prompt "Is $interface the correct network interface:"
        if [[ $REPLY == "y" ]]; then
            dhcpcd $interface
            break
        fi
    fi
done

echo "Setting timezone to ${TIMEZONE}"
ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime

echo "Setting hostname to ${HOSTNAME}"
echo "${HOSTNAME}" > /etc/hostname

echo "Creating user: ${USR}"
useradd -m -G wheel,floppy,audio,video,optical,cdrom -s /bin/bash $USR
passwd $USR

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/default/libc-locales
xbps-reconfigure -f glibc-locales

# setup fstab
vim /etc/fstab

vim /etc/rc.conf

# install and configure refind
refind-install
vim /boot/refind_linux.conf

# setup mulilib and nonfree repos
xbps-install -Sy void-repo-multilib void-repo-multilib-nonfree void-repo-nonfree

# change mirror to one in the united states
mkdir -p /etc/xbps.d/
cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
sed -i 's|https://alpha.de.repo.voidlinux.org|http://alpha.us.repo.voidlinux.org|g' /etc/xbps.d/*-repository-*.conf

# update
xbps-install -Suy
