DOTFILES_PATH  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DOTFILE_RC     := vim zsh
DOTFILE_CONFIG := awesome dwb
DOTFILE        := gitconfig tmux.conf xprofile gvimrc
DOTFILES       := $(DOTFILE_RC) $(DOTFILE_CONFIG) $(DOTFILE)

.PHONY: all $(DOTFILES) zsh-custom

all: $(DOTFILES) zsh-custom

$(DOTFILE_RC):
	[ -f ~/.$@rc ] || \
		rm -Rf ~/.$@rc
	[ -f ~/.$@ ] || \
		rm -Rf ~/.$@
	ln -sf $(DOTFILES_PATH)$@rc ~/.$@rc
	ln -sf $(DOTFILES_PATH)$@ ~/.$@

zsh-custom:
	$(foreach plugin, $(shell ls $(DOTFILES_PATH)zsh-custom), \
		[ ! -f $(DOTFILES_PATH)zsh-custom/$(plugin) ] || \
			ln -s $(DOTFILES_PATH)/zsh-custom/$(plugin) $(DOTFILES_PATH)zsh/custom/plugins;)

$(DOTFILE_CONFIG):
	mkdir -p ~/.config
	[ -f ~/.config/$@ ] || \
		rm -Rf ~/.config/$@
	ln -sf $(DOTFILES_PATH)$@ ~/.config/$@

$(DOTFILE):
	[ -f ~/.$@ ] || \
		rm -Rf ~/.$@
	ln -sf $(DOTFILES_PATH)$@ ~/.$@
