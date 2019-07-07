MKSWAP=1
DATADRIVE=0

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
PACKAGES="xorg cinnamon emacs-gtk3 git zsh tmux firefox rxvt-unicode weechat mpd ncmpcpp gnupg2 libreoffice curl vpsm"
KEYMAP="us"
REPOS="void-repo-multilib void-repo-multilib-nonfree void-repo-nonfree"
