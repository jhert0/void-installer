MKSWAP=0
MUSL=0

ROOTLUKS="tank"
DATALUKS="data"

BTRFS_OPTS="rw,noatime,compress=zstd,space_cache"

INTERFACE="eno1"

HOSTNAME="localhost"
TIMEZONE="America/Chicago"
KEYMAP="us"

# Packages

REPO="http://alpha.us.repo.voidlinux.org"
REPOS="void-repo-multilib void-repo-multilib-nonfree void-repo-nonfree"

DE="xfce4"
DE_EXTRAS="xfce4-whiskermenu-plugin xfce4-pulseaudio-plugin libreoffice pinentry-gtk gnome-disk-utility greybird-themes connman-gtk firefox alacritty mpv sxiv"

SHELL="zsh"

DEVELOPMENT="base-devel git emacs-gtk3 neovim"

PACKAGES="tmux mpd ncmpcpp gnupg2 curl vpsm connman rsync "
PACKAGES+=" pulseaudio zip unzip font-iosevka feh python dunst aerc htop ripgrep picom"
PACKAGES+=" ${DE} ${DE_EXTRAS} ${SHELL} ${DEVELOPMENT}"
