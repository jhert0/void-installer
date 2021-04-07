#!/bin/bash

RDISK=$1
ROOT=$2
BOOT=$3
DATA=$4
USR=$5

source config.sh

dhcpcd $INTERFACE

chown root:root /
chmod 755 /

# disable copy on write for the vms folder
if [[ $DATA != "" ]]; then
    chattr +C /mnt/vault/vms
fi

echo "Setting timezone to ${TIMEZONE}"
ln -s /usr/share/zoneinfo/$TIMEZONE /etc/localtime

ntpdate -s time.nist.gov

echo "Setting hostname to ${HOSTNAME}"
echo "${HOSTNAME}" > /etc/hostname

echo "Creating user: ${USR}"
useradd -m -G wheel,floppy,audio,video,optical,cdrom -s /bin/bash $USR
pwconv

echo "Changing password for ${USR}"
passwd $USR

echo "Chaning password for root"
passwd root

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/default/libc-locales
xbps-reconfigure -f glibc-locales

# setup fstab
echo "Setting up /etc/fstab"

root_uuid=$(blkid $ROOT --output export | grep "UUID=" | cut -d ' ' -f 2 | tr -d ' ')
boot_uuid=$(blkid $BOOT --output export | grep "UUID=" | cut -d ' ' -f 2 | tr -d ' ')

echo "UUID=${root_uuid}  / btrfs  $BTRFS_OPTS,subvol=@ 0 1" > /etc/fstab
echo "UUID=${root_uuid}  /home btrfs  $BTRFS_OPTS,subvol=@home 0 1" >> /etc/fstab
echo "UUID=${boot_uuid}  /boot  vfat  rw,relatime  0 0" >> /etc/fstab

if [[ $DATA != "" ]]; then
    data_uuid=$(blkid $DATA --output export | grep "UUID=" | cut -d ' ' -f 2 | tr -d ' ')
    echo "UUID=${data_uuid}  /mnt/vault  btrfs $BTRFS_OPTS,subvol=@vault  0 1" >> /etc/fstab
    echo "UUID=${data_uuid}  /mnt/snapshots btrfs  $BTRFS_OPTS,subvol=@snapshots 0 1" >> /etc/fstab
    echo "data UUID=${data_uuid} /root/data.key" > /etc/crypttab
fi

echo "tmpfs  /tmp  tmpfs  defaults,nosuid,nodev  0 0" >> /etc/fstab

echo "Setting up /etc/rc.conf"
echo "TIMEZONE=${TIMEZONE}" > /etc/rc.conf
echo "KEYMAP=${KEYMAP}" >> /etc/rc.conf

# install and configure refind
refind-install
echo "\"Boot with standard options\" \"root=UUID=${root_uuid} rootflags=subvol=@ rw quiet initrd=/initramfs-%v.img rd.auto=1 init=/sbin/init vconsole.unicode=1 vconsole.keymap=${KEYMAP}\"" > /boot/refind_linux.conf

# setup extra repos
xbps-install -Sy $REPOS

# change mirror to one in the united states
mkdir -p /etc/xbps.d/
cp /usr/share/xbps.d/*-repository-*.conf /etc/xbps.d/
sed -i "s|https://alpha.de.repo.voidlinux.org|$REPO|g" /etc/xbps.d/*-repository-*.conf

xbps-install -Syu
xbps-install -Sy $PACKAGES
