# @ch3sh1r dotfiles

## Installation

### Using Git and the push script

You can clone the repository wherever you want. (I like to keep it in `~/Projects/dotfiles`, with symlinks to `~`) Pusher script will pull in the latest version and copy the files to your home folder.

    git clone https://github.com/ch3sh1r/dotfiles.git && cd dotfiles && ./push.sh

To update, `cd` into your local `dotfiles` repository and then:

    ./push.sh

To update while avoiding the confirmation prompt:

    ./push.sh -f

To create symlinks instead of update:

    ./push.sh -f

### Git-free install

To get these dotfiles without Git:

    cd; wget https://github.com/ch3sh1r/dotfiles/tarball/master

Then unpack them and execute `push.sh` manually.

