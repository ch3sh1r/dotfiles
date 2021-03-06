DOTFILES_PATH  := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DOTFILE_RC     := vim zsh
DOTFILE        := gitconfig tmux.conf xprofile gvimrc
DOTFILES       := $(DOTFILE_RC) $(DOTFILE) emacs zsh-custom

.PHONY: all $(DOTFILES)

all: $(DOTFILES)

emacs:
	rm -Rf ~/.spacemacs
	rm -Rf ~/.emacs.d
	ln -sf $(DOTFILES_PATH)spacemacs ~/.spacemacs
	ln -sf $(DOTFILES_PATH)emacs.d ~/.emacs.d

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

$(DOTFILE):
	rm -Rf ~/.$@
	ln -sf $(DOTFILES_PATH)$@ ~/.$@
