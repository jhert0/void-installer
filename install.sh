#!/bin/bash

if [[ ! -d /sys/firmware/efi ]];then
    echo "This script does not currently support BIOS mode."
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

yes_no_prompt(){
    read -p "$1 [y/N] "
}

contains_element(){
    for e in "${@:2}"; do [[ $e == $1 ]] && break; done;
}

create_swap(){
    echo "Creating swap on ${SWAP}..."
    mkswap $SWAP
    swapon $SWAP
}

format_root(){
    echo "Formatting ${ROOT}..."
    mkfs.ext4 $ROOT
}

format_data(){
    echo "Formatting ${DATA}..."
    mkfs.ext4 $DATA
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

setup_lvm(){
    echo "Please create the lvm."
    cfdisk $RDISK
    if [[ $DDISK != "none" ]]; then
        cfdisk $DDISK
    fi
}

setup_luks(){
    echo "Encrypting hard drive..."

    select_partition "Select root partition"
    cryptsetup luksFormat $PARTITION
    cryptsetup open $PARTITION main
    pvcreate /dev/mapper/main

    vgcreate $VOLUME /dev/mapper/main

    if [[ $DDISK != "none" ]]; then
        select_partition "Select data partition"
        cryptsetup luksFormat $PARTITION
        cryptsetup open $PARTITION data
        pvcreate /dev/mapper/data
        vgextend $VOLUME /dev/mapper/data #add data to the volume
        lvcreate -l $DATASIZE $VOLUME -n data /dev/mapper/data
    fi

    if [[ $MKSWAP == 1 ]]; then
        lvcreate -L $SWAPSIZE $VOLUME -n swap /dev/mapper/main
    fi

    lvcreate -l $ROOTSIZE $VOLUME -n root /dev/mapper/main
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
                cfdisk $DISK
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
    mount $ROOT /mnt

    mkdir /mnt/{boot,dev,proc,sys}

    mount $BOOT /mnt/boot
    mount --rbind /dev/ /mnt/dev
    mount --rbind /proc/ /mnt/proc
    mount --rbind /sys/ /mnt/sys

    xbps-install -Sy -R http://alpha.us.repo.voidlinux.org/current/ -r /mnt base-system lvm2 cryptsetup refind vim
}

loadkeys $KEYMAP

boot_partition
setup_lvm
setup_luks
format_root
if [[ $MKSWAP == 1 ]]; then
    create_swap
fi
if [[ $DDISK != "none" ]]; then
    format_data
fi
bootstrap

cp ./chroot.sh /mnt/
cp ./config.sh /mnt/

chroot /mnt ./chroot.sh $RDISK $USR

# cleanup
rm /mnt/chroot.sh /mnt/config.sh

echo "If there is anything else you would like to do run:"
echo "chroot /mnt /bin/bash"

if [[ $DDISK != "none" ]]; then
    echo "Don't forget to setup /etc/crypttab and dracut"
fi
