DOTFILE        := gitconfig vimrc
DOTFILE_CONFIG := fish i3 i3status alacritty hypr quickshell tmux nvim btop fuzzel lazygit dunst
DOTFILE_BIN    := egpu mnf tdp timer cliphist-fuzzel-img ocr-region
DOTFILES       := $(DOTFILE_CONFIG) $(DOTFILE_BIN) $(DOTFILE)
DOTFILES_PATH  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
PACKAGE_LIST   := gpd-p3.list

.PHONY: all $(DOTFILES) packages-install

all: $(DOTFILES)

$(DOTFILE_CONFIG):
	mkdir -p ~/.config
	rm -Rf ~/.config/$@
	ln -sf $(DOTFILES_PATH)$@ ~/.config/$@

$(DOTFILE_BIN):
	mkdir -p ~/.local/bin
	rm -Rf ~/.local/bin/$@
	ln -sf $(DOTFILES_PATH)bin/$@ ~/.local/bin/$@

$(DOTFILE):
	rm -Rf ~/.$@
	ln -sf $(DOTFILES_PATH)$@ ~/.$@

packages-install:
	@if ! command -v paru >/dev/null 2>&1; then \
		tmpdir=$$(mktemp -d); \
		trap 'rm -rf "$$tmpdir"' EXIT; \
		sudo pacman -S --needed git base-devel; \
		git clone https://aur.archlinux.org/paru.git "$$tmpdir/paru"; \
		makepkg -si --needed --noconfirm -D "$$tmpdir/paru"; \
	fi
	paru -S --needed $$(sed '/^[[:space:]]*#/d; /^[[:space:]]*$$/d' $(DOTFILES_PATH)$(PACKAGE_LIST))
