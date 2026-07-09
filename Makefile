DOTFILE        := gitconfig vimrc
DOTFILE_CONFIG := fish i3 i3status alacritty hypr quickshell tmux nvim btop lazygit
DOTFILE_BIN    := egpu mnf tdp timer ocr-region
DOTFILES       := $(DOTFILE_CONFIG) $(DOTFILE_BIN) $(DOTFILE)
DOTFILES_PATH  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PACKAGE_LIST   := gpd-p3.list

.PHONY: all $(DOTFILES) packages-install

all: $(DOTFILES)

$(DOTFILE_CONFIG):
	@mkdir -p ~/.config
	@if [ -e ~/.config/$@ ] && [ ! -L ~/.config/$@ ]; then \
		echo "~/.config/$@ exists and is not a symlink; move it away first"; exit 1; \
	fi
	ln -sfn $(DOTFILES_PATH)$@ ~/.config/$@

$(DOTFILE_BIN):
	@mkdir -p ~/.local/bin
	@if [ -e ~/.local/bin/$@ ] && [ ! -L ~/.local/bin/$@ ]; then \
		echo "~/.local/bin/$@ exists and is not a symlink; move it away first"; exit 1; \
	fi
	ln -sfn $(DOTFILES_PATH)bin/$@ ~/.local/bin/$@

$(DOTFILE):
	@if [ -e ~/.$@ ] && [ ! -L ~/.$@ ]; then \
		echo "~/.$@ exists and is not a symlink; move it away first"; exit 1; \
	fi
	ln -sfn $(DOTFILES_PATH)$@ ~/.$@

packages-install:
	@if ! command -v paru >/dev/null 2>&1; then \
		tmpdir=$$(mktemp -d); \
		trap 'rm -rf "$$tmpdir"' EXIT; \
		sudo pacman -S --needed git base-devel; \
		git clone https://aur.archlinux.org/paru.git "$$tmpdir/paru"; \
		makepkg -si --needed --noconfirm -D "$$tmpdir/paru"; \
	fi
	paru -S --needed $$(sed '/^[[:space:]]*#/d; /^[[:space:]]*$$/d' $(DOTFILES_PATH)$(PACKAGE_LIST))
