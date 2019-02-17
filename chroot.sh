#!/bin/sh

DISK=$1
USR=$2
PASSWORD=$3

create_user(){
    useradd -m -G wheel floppy audio video optical cdrom -s /bin/bash $USR
    passwd
}

chown root:root /
chmod 755 /

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/default/libc-locales
xbps-reconfigure -f glibc-locales

vim /etc/fstab

refind-install
