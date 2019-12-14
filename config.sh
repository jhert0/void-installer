MKSWAP=1

VOLUME="volume"

BOOT=""
ROOT="/dev/mapper/$VOLUME-root"
SWAP="/dev/mapper/$VOLUME-swap"
DATA="/dev/mapper/$VOLUME-data"

ROOTSIZE="100%FREE"
SWAPSIZE="4G"
DATASIZE="100%FREE"

HOSTNAME="localhost"
TIMEZONE="America/Chicago"
REPO="http://alpha.us.repo.voidlinux.org"
PACKAGES="xorg cinnamon emacs-gtk3 git zsh tmux firefox rxvt-unicode mpd ncmpcpp gnupg2 libreoffice curl vpsm vim connman pulseaudio"
KEYMAP="us"
REPOS="void-repo-multilib void-repo-multilib-nonfree void-repo-nonfree"
