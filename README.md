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


Fish plugins (fisher, z) are not committed. Install them from
`fish/fish_plugins` with:

```bash
make fish-plugins
```

## Dictation for Codex

Voxtype transcribes locally and copies the result to the Wayland clipboard.
Install `voxtype-bin` (listed in `gpd-p3.list`) and download the multilingual
Whisper model with `voxtype setup --download --model small`. Download
`large-v3-turbo` the same way for higher-accuracy dictation. Enable the
packaged service once so it starts with the graphical session:

```bash
systemctl --user enable --now voxtype.service
```

Russian is fixed as the recognition language. Press `Super+D` to toggle fast
dictation (`small`), or `Super+Shift+D`
to toggle higher-accuracy dictation (`large-v3-turbo`). Use the same shortcut
to stop the recording. Review the result, then paste it into Codex in Alacritty
with `Ctrl+Shift+V`. Quickshell keeps a red recording timer or an amber speech
recognition indicator on screen until that phase finishes.
`Super+V` opens the existing clipboard history if you need an earlier result.
