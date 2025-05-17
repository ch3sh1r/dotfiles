DOTFILE        := gitconfig tmux.conf vimrc
DOTFILE_CONFIG := fish i3 i3status alacritty hypr waybar nvim
DOTFILES       := $(DOTFILE_CONFIG) $(DOTFILE)
DOTFILES_PATH  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: all $(DOTFILES)

all: $(DOTFILES)

$(DOTFILE_CONFIG):
	mkdir -p ~/.config
	rm -Rf ~/.config/$@
	ln -sf $(DOTFILES_PATH)$@ ~/.config/$@

$(DOTFILE):
	rm -Rf ~/.$@
	ln -sf $(DOTFILES_PATH)$@ ~/.$@

