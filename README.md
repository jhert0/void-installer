# void-installer

Install script for Void Linux. This install script will create an encrypted install using LVM and LUKS. You can optionally setup a data drive that is also encrypted.

**WARNING:** This script assumes sizes for the root, swap, and data logical volumes, it's setup the way I like but can be changed easily. This script also assumes you are using UEFI, this should be another thing that should be easy to change if you would rather or need to use BIOS.

## Usage

Run:
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

## Defaults

This is what the script will create on the LVM partition.

There will be 2 physical volumes created in the volume group called `volume`.

| name | volume name |
|------|-------------|
| main | volume      |
| data | volume      |

There will be up to 3 logical volumes created. The root and swap will be on the main physical volume and the data logical volume will be created on the data physical volume.

| name            | size     | physical volume  |
|-----------------|----------|------------------|
| root            | 100%FREE | /dev/mapper/main |
| swap            | 4GB      | /dev/mapper/main |
| data (optional) | 100%FREE | /dev/mapper/data |
