MKSWAP=1

VOLUME="volume"

BOOT=""
ROOT="/dev/mapper/$VOLUME-root"
SWAP="/dev/mapper/$VOLUME-swap"
DATA="/dev/mapper/$VOLUME-data"

ROOTSIZE="100%FREE"
SWAPSIZE="4G"
DATASIZE="100%FREE"

INTERFACE="eno1"

UEFI=1

HOSTNAME="localhost"
TIMEZONE="America/Chicago"
REPO="http://alpha.us.repo.voidlinux.org"
PACKAGES="xorg cinnamon emacs-gtk3 git zsh tmux firefox alacritty mpd ncmpcpp gnupg2 libreoffice curl vpsm neovim vim connman connman-gtk pulseaudio pinentry-gtk zip unzip font-iosevka"
PACKAGES+=" qutebrowser feh base-devel python gnome-disk-utility greybird-themes font-symbola dunst xautolock slock"
KEYMAP="us"
REPOS="void-repo-multilib void-repo-multilib-nonfree void-repo-nonfree"
