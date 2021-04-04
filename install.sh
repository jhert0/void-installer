#!/bin/bash

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <root disk> <data disk|none> <username>"
    exit 1
fi

if [[ ! -d /sys/firmware/efi ]];then
    echo "Script set to install uefi compatible bootloader but you did not boot using uefi"
    exit 1
fi

if [[ $1 == "" ]]; then
    echo "Please enter the root disk."
    exit 1
fi

if [[ $2 == "" ]]; then
   echo "Please enter the data disk. Enter none if you don't want to create one."
   exit 1
fi

if [[ $3 == "" ]]; then
    echo "Please enter the username of your account."
    exit 1
fi

RDISK=$1 #root disk
DDISK=$2 #data disk
USR=$3 #username

source config.sh

PARTITION=""

BOOT=""
ROOT=""
HOME=""
DATA=""

yes_no_prompt(){
    read -p "$1 [y/N] "
}

contains_element(){
    for e in "${@:2}"; do [[ $e == $1 ]] && break; done;
}

select_partition(){
    partitions_list=`lsblk | grep 'part' | awk '{print "/dev/" substr($1,3)}'`;
    PS3="$1: "
    select partition in $partitions_list; do
        if contains_element $partition; then
            yes_no_prompt "Is $partition the correct partition:"
            if [[ $REPLY == "y" ]]; then
                PARTITION=$partition
                break
            fi
        fi
    done
}

config_disks(){
    cfdisk $RDISK

    if [[ $DDISK != "none" ]]; then
        cfdisk $DDISK
    fi
}

setup_luks(){
    select_partition "Select root partition"

    echo "Encrypting ${PARTITION}..."
    cryptsetup luksFormat $PARTITION
    cryptsetup open $PARTITION $ROOTLUKS

    if [[ $DDISK != "none" ]]; then
        select_partition "Select data partition"

        dd if=/dev/random of=data.key bs=1 count=32

        cryptsetup luksFormat $PARTITION data.key
        cryptsetup open $PARTITION $DATALUKS --key-file data.key

        DATA=/dev/mapper/$DATALUKS
    fi

    ROOT=/dev/mapper/$ROOTLUKS
}

mount_filesytems(){
    mount -o $BTRFS_OPTS,subvol=@ $ROOT /mnt

    mkdir -p /mnt/{boot,dev,proc,sys,home,mnt,var}

    mount -o $BTRFS_OPTS,subvol=@home $ROOT /mnt/home

    # create seperate subvolumes for log, cache, and tmp to prevent them
    # from being in snapshots of the root subvolume
    btrfs subvolume create /mnt/var/log
    btrfs subvolume create /mnt/var/cache
    btrfs subvolume create /mnt/var/tmp

    mount $BOOT /mnt/boot

    mount --rbind /dev/ /mnt/dev
    mount --rbind /proc/ /mnt/proc
    mount --rbind /sys/ /mnt/sys

    if [[ $DDISK != "none" ]]; then
        # move the key for the data drive to the root filesystem
        mkdir -p /mnt/root
        mv data.key /mnt/root

        mkdir -p /mnt/mnt/{vault,snapshots}
        mount -o $BTRFS_OPTS,subvol=@vault $DATA /mnt/mnt/vault
        mount -o $BTRFS_OPTS,subvol=@snapshots $DATA /mnt/mnt/snapshots

        btrfs subvolume create /mnt/mnt/vault/storage
        btrfs subvolume create /mnt/mnt/vault/vms
    fi
}

setup_btrfs(){
    mkfs.btrfs -L root -d single -m single $ROOT

    mount -o $BTRFS_OPTS $ROOT /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    umount /mnt

    if [[ $DDISK != "" ]]; then
        mkfs.btrfs -L data -d single -m dup $DATA

        mount -o $BTRFS_OPTS $DATA /mnt
        btrfs subvolume create /mnt/@vault
        btrfs subvolume create /mnt/@snapshots
        umount /mnt
    fi
}

boot_partition(){
    PS3="Do you need to create a boot partion: "
    options=("y" "n")
    select opt in "${options[@]}"; do
        case "$opt" in
            "n")
                echo "Using existing boot partition."
                select_partition "Select boot partition"
                BOOT=$PARTITION
                break
                ;;
            "y")
                echo "Going to create a boot partition."
                cfdisk $RDISK
                select_partition "Select boot partition"
                BOOT=$PARTITION
                mkfs.vfat -F 32 $BOOT
                break
                ;;
            *) echo Invalid;;
        esac
    done
}

bootstrap(){
    repo="$REPO/current/"
    if [[ $MUSL -eq 1 ]]; then
        repo="$REPO/current/musl/"
    fi

    xbps-install -Sy -R $repo -r /mnt base-system btrfs-progs cryptsetup ntp refind vim
    xbps-reconfigure -r /mnt -f base-files
    chroot /mnt xbps-reconfigure -a
}

echo "------------------------------------------------"
echo "Username: ${USR}"
echo "Root disk: ${RDISK}"
echo "Data disk: ${DDISK}"
echo "Root LUKS: ${ROOTLUKS}"
echo "Data LUKS: ${DATALUKS}"
echo "------------------------------------------------"

yes_no_prompt "Does the information above look correct"
if [[ $REPLY == "n" ]]; then
    echo "Aborting"
    exit 1
fi

loadkeys $KEYMAP

boot_partition

config_disks
setup_luks
setup_btrfs
mount_filesytems
bootstrap

cp ./chroot.sh /mnt/
cp ./config.sh /mnt/

chroot /mnt ./chroot.sh $RDISK $ROOT $BOOT $DATA $USR

# cleanup
rm /mnt/chroot.sh /mnt/config.sh

if [[ $DDISK != "none" ]]; then
    echo "Don't forget to setup /etc/crypttab and dracut"
fi
