# @ch3sh1r's dotfiles

## Installation

Symlinks configs into `~/.config`, `~/.local/bin` and `~`. Existing real
(non-symlink) files are left untouched — `make` will refuse and ask you to
move them away first.

```bash
git clone --recursive https://github.com/ch3sh1r/dotfiles ~/.local/dotfiles
cd ~/.local/dotfiles
make
```

