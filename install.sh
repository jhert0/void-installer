#!/bin/bash

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

if [[ $4 == "" ]]; then
    echo "Please enter the password to your account"
    exit 1
fi

RDISK=$1 #root disk
DDISK=$2 #data disk
PARTITION=""

VOLUME="volume"
BOOT=""
ROOT="/dev/mapper/$VOLUME-root"
SWAP="/dev/mapper/$VOLUME-swap"
DATA="/dev/mapper/$VOLUME-data"

USR=$3
PASSWORD=$4

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
    partitions_list=(`lsblk | grep 'part' | awk '{print "/dev/" substr($1,3)}'`);
    PS3="Select a partition: "
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

    select_partition
    cryptsetup luksFormat $PARTITION
    cryptsetup open $PARTITION lvm
    pvcreate /dev/mapper/lvm

    vgcreate $VOLUME /dev/mapper/lvm

    if [[ $DDISK != "none" ]]; then
        select_partition
        cryptsetup luksFormat $PARTITION
        cryptsetup open $PARTITION data
        pvcreate /dev/mapper/data
        vgextend $VOLUME /dev/mapper/data #add data to the volume
        lvcreate -l 100%FREE $VOLUME -n data $DDISK
    fi

    lvcreate -L 4GB $VOLUME -n swap $RDISK
    lvcreate -l 100%FREE $VOLUME -n root $RDISK
}

boot_partition(){
    PS3="Do you need to create a boot partion: "
    options=("y" "n")
    select opt in "${options[@]}"; do
        case "$opt" in
            "n")
                echo "Using existing boot partition."
                select_partition
                BOOT=$PARTITION
                break
                ;;
            "y")
                echo "Going to create a boot partition."
                cfdisk $DISK
                select_partition
                $BOOT=$PARTITION
                mkfs.fat -F 32 $BOOT
                break
                ;;
            *) echo Invalid;;
        esac
    done
}

bootstrap(){
    mkdir /mnt/{boot,dev,proc,sys}

    mount $ROOT /mnt
    mount $BOOT /mnt/boot
    mount --rbind /dev/ /mnt/dev
    mount --rbind /proc/ /mnt/proc
    mount --rbind /sys/ /mnt/sys

    xbps-install -S -R http://alpha.us.repo.voidlinux.org/current/ -r /mnt base-system lvm2 cryptsetup refind vim
}

loadkeys us

boot_partition
setup_lvm
setup_luks
format_root
create_swap
if [[ $DDISK != "none" ]]; then
    format_data
fi
bootstrap

cp ./chroot.sh /mnt/
cp ./shared.sh /mnt/

chroot /mnt ./chroot.sh $RDISK $USR $PASSWORD

# cleanup
rm /mnt/chroot.sh /mnt/shared.sh
