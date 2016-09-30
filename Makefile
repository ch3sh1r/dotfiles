DOTFILES_PATH  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DOTFILE_RC     := vim zsh
DOTFILE_CONFIG := awesome
DOTFILE        := gitconfig tmux.conf xprofile gvimrc
DOTFILES       := $(DOTFILE_RC) $(DOTFILE_CONFIG) $(DOTFILE)

.PHONY: all $(DOTFILES) zsh-custom

all: $(DOTFILES) zsh-custom

$(DOTFILE_RC):
	rm -Rf ~/.$@rc
	rm -Rf ~/.$@
	ln -sf $(DOTFILES_PATH)$@rc ~/.$@rc
	ln -sf $(DOTFILES_PATH)$@ ~/.$@

zsh-custom:
	$(foreach file, $(shell ls $(DOTFILES_PATH)zsh-custom/*.zsh), \
		[ -L $(DOTFILES_PATH)zsh/custom/$(shell basename $(file)) ] || \
			ln -s $(file) $(DOTFILES_PATH)zsh/custom;)
	$(foreach plugin, $(shell ls $(DOTFILES_PATH)zsh-custom/plugins), \
		[ -L $(DOTFILES_PATH)zsh/custom/plugins/$(plugin) ] || \
			ln -s $(DOTFILES_PATH)zsh-custom/plugins/$(plugin) $(DOTFILES_PATH)zsh/custom/plugins;)

$(DOTFILE_CONFIG):
	mkdir -p ~/.config
	rm -Rf ~/.config/$@
	ln -sf $(DOTFILES_PATH)$@ ~/.config/$@

$(DOTFILE):
	rm -Rf ~/.$@
	ln -sf $(DOTFILES_PATH)$@ ~/.$@
