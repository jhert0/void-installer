#!/bin/sh

DISK=$1
USR=$2

HOSTNAME="localhost"

chown root:root /
chmod 755 /

echo "Setting hostname to ${HOSTNAME}"
echo $HOSTNAME > /etc/hostname

echo "Creating user: ${USR}"
useradd -m -G wheel floppy audio video optical cdrom -s /bin/bash $USR
passwd $USR

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/default/libc-locales
xbps-reconfigure -f glibc-locales

vim /etc/fstab

refind-install

vim /boot/refind_linux.conf
