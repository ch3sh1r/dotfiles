DOTFILES      := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DTFILE_CONFIG := awesome dwb
DTFILE        := gitconfig tmux.conf xprofile

.PHONY: all default \
		zsh vim awesome dwb gitconfig tmux.conf xprofile

all: zsh vim awesome dwb gitconfig tmux.conf xprofile

zsh:
	rm -Rf ~/.zshrc
	rm -Rf ~/.zsh
	ln -sf $(DOTFILES)zshrc ~/.zshrc
	ln -sf $(DOTFILES)zsh ~/.zsh

vim:
	rm -Rf ~/.gvimrc
	rm -Rf ~/.vimrc
	rm -Rf ~/.vim
	ln -sf $(DOTFILES)gvimrc ~/.gvimrc
	ln -sf $(DOTFILES)vimrc ~/.vimrc
	ln -sf $(DOTFILES)vim ~/.vim

$(DTFILE_CONFIG):
	mkdir -p ~/.config
	rm -Rf ~/.config/$@
	ln -sf $(DOTFILES)$@ ~/.config/$@

$(DTFILE):
	rm -Rf ~/.$@
	ln -sf $(DOTFILES)$@ ~/.$@
