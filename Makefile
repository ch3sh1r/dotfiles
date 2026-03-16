DOTFILE        := gitconfig tmux.conf vimrc
DOTFILE_CONFIG := fish i3 i3status alacritty hypr waybar nvim btop fuzzel
DOTFILE_BIN    := egpu mnf tdp timer cliphist-fuzzel-img totem-bat
DOTFILES       := $(DOTFILE_CONFIG) $(DOTFILE_BIN) $(DOTFILE)
DOTFILES_PATH  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: all $(DOTFILES)

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

