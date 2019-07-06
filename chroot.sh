#!/bin/bash

USR=$1

HOSTNAME="localhost"
TIMEZONE="America/Chicago"
REPO="http://alpha.us.repo.voidlinux.org"
PACKAGES="xorg cinnamon emacs-gtk3 git zsh tmux firefox rxvt-unicode weechat mpd ncmpcpp gnupg2 libreoffice curl vpsm"
KEYMAP="us"

chown root:root /
chmod 755 /

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
echo "Setting up /etc/fstab"
vim /etc/fstab

echo "Setting up /et/rc.conf"
echo "TIMEZONE=${TIMEZONE}" >> /etc/rc.conf
echo "KEYMAP=${KEYMAP}" >> /etc/rc.conf

# install and configure refind
refind-install
vim /boot/refind_linux.conf

# setup mulilib and nonfree repos
xbps-install -Sy void-repo-multilib void-repo-multilib-nonfree void-repo-nonfree

# change mirror to one in the united states
mkdir -p /etc/xbps.d/
cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
sed -i 's|https://alpha.de.repo.voidlinux.org|${REPO}|g' /etc/xbps.d/*-repository-*.conf

# update
xbps-install -Syu

xbps-install -S $PACKAGES
