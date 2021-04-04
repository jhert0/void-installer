# void-installer

Install script for Void Linux. This install script will create an encrypted install using btrfs and LUKS. You can optionally setup a data drive that is also encrypted. 

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

The following will be created on the btrfs partition on the root disk:

| name  | path  |
|-------|-------|
| @     | /     |
| @home | /home |

Subvolumes will also be created at /var/log /var/cache /var/tmp on the @
subvolume.

The following will be created on the btrfs partition on the data disk:

| name       | path           |
|------------|----------------|
| @snapshots | /mnt/snapshots |
| @vault     | /mnt/vault     |

Subvolumes will also be created at /mnt/vault/vms and /mnt/vault/storage
on the @vault subvolume.
