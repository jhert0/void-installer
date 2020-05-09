# void-installer

Install script for Void Linux. This install script will create an encrypted install using LVM and LUKS. You can optionally setup a data drive that is also encrypted. 

## Usage

1. Setup your internet connection.
2. Run:
```bash
./install <root disk> <data disk> <username>
```

Example:
```bash
./install /dev/sda /dev/sdb endoffile
```

If you do not want to setup a data drive then pass none instead. Example:
```bash
./install /dev/sda none endoffile
```

## Configuration

Included in this repo is a configuration file where you can change things such as the size of the partitions, timezone, keymap, etc. Below you can see the [defaults](#defaults).

<a href="#defaults"></a>
## Defaults
### Hard Drives

This is what the script will create on the LVM partition using the default configuration.

There will be 2 physical volumes created in the volume group called `volume`.

| name | volume group |
|------|--------------|
| main | volume       |
| data | volume       |

There will be up to 3 logical volumes created. The root and swap will be on the main physical volume and the data logical volume will be created on the data physical volume. Swap is optional but by default it it will be created, change the `MKSWAP` variable to 0 to disable creating the swap.

| name            | size     | physical volume  |
|-----------------|----------|------------------|
| root            | 100%FREE | /dev/mapper/main |
| swap (optional) | 4GB      | /dev/mapper/main |
| data (optional) | 100%FREE | /dev/mapper/data |

### Bootloader

The script is set to install rEFInd by default, if you would like to use GRUB change the UEFI variable in config.sh to 0.

#### rEFInd

Nothing should need to be done after rEFInd is installed.

#### GRUB

GRUB currently only supports luks1, support for luks2 has been added to GRUB but it has not been released yet. The script will automatically switch to luks1 when GRUB is going to be installed, this will be removed once support for luks2 has been released. GRUB may also require additional configuration after the script finishes, support for GRUB is still being worked on.
