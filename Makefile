DOTFILES_PATH  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DOTFILE_RC     := vim
DOTFILE_CONFIG := fish
DOTFILE        := gitconfig tmux.conf xprofile gvimrc
DOTFILES       := $(DOTFILE_RC) $(DOTFILE_CONFIG) $(DOTFILE)

.PHONY: all $(DOTFILES)

all: $(DOTFILES)

$(DOTFILE_RC):
	rm -Rf ~/.$@rc
	rm -Rf ~/.$@
	ln -sf $(DOTFILES_PATH)$@rc ~/.$@rc
	ln -sf $(DOTFILES_PATH)$@ ~/.$@

$(DOTFILE_CONFIG):
	mkdir -p ~/.config
	rm -Rf ~/.config/$@
	ln -sf $(DOTFILES_PATH)$@ ~/.config/$@

$(DOTFILE):
	rm -Rf ~/.$@
	ln -sf $(DOTFILES_PATH)$@ ~/.$@

