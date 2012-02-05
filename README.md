# Mathias’s dotfiles

## Installation

### Using Git and the push script

You can clone the repository wherever you want. (I like to keep it in `~/Projects/dotfiles`, with symlinks to ~.) The pusher script will pull in the latest version and copy the files to your home folder.

```bash
git clone https://github.com/ch3sh1r/dotfiles.git && cd dotfiles && ./push.sh
```

To update, `cd` into your local `dotfiles` repository and then:

```bash
./push.sh
```

To update while avoiding the confirmation prompt:

```bash
./push.sh -f
```

To create symlinks instead of update:

```bash
./push.sh -f
```

### Git-free install

To get these dotfiles without Git:

```bash
cd; wget https://github.com/ch3sh1r/dotfiles/tarball/master
```

Then unpack them and execute manually.
