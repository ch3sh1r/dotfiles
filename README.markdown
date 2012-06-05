# @ch3sh1r dotfiles

## Installation

### Using Git

You can clone the repository wherever you want (i like to keep it in 
`~/<long_way_to_code_directory>/dotfiles`, with symlinks to `~`):

    git clone https://github.com/ch3sh1r/dotfiles.git && cd dotfiles && ./push.sh -l

But some times it's comfortable just minimal installation without 
dependencies. When only needed files (without wm configuration for me)
can be copied to `~` by:

    ./push.sh -f

### Git-free

To get these dotfiles tarball without Git:

    cd; wget https://github.com/ch3sh1r/dotfiles/tarball/master

Then unpack them by `tar xzf dotfiles` and execute `./push.sh` manually.

