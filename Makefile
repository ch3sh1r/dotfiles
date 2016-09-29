MKFILE_PATH   := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_DIR   := $(dir $(MKFILE_PATH))

DTFILE_CONFIG := awesome dwb
DTFILE        := gitconfig tmux.conf xprofile

.PHONY: all default \
		zsh vim awesome dwb gitconfig tmux.conf xprofile

all: zsh vim awesome dwb gitconfig tmux.conf xprofile

zsh:
	rm -Rf ~/.zshrc
	rm -Rf ~/.zsh
	ln -sf $(CURRENT_DIR)zshrc ~/.zshrc
	ln -sf $(CURRENT_DIR)zsh ~/.zsh

vim:
	rm -Rf ~/.gvimrc
	rm -Rf ~/.vimrc
	rm -Rf ~/.vim
	ln -sf $(CURRENT_DIR)gvimrc ~/.gvimrc
	ln -sf $(CURRENT_DIR)vimrc ~/.vimrc
	ln -sf $(CURRENT_DIR)vim ~/.vim

$(DTFILE_CONFIG):
	mkdir -p ~/.config
	rm -Rf ~/.config/$@
	ln -sf $(CURRENT_DIR)$@ ~/.config/$@

$(DTFILE):
	rm -Rf ~/.$@
	ln -sf $(CURRENT_DIR)$@ ~/.$@
