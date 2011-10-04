#!/bin/sh

# Dumb script that push all files to right places.

mkdir /tmp/dotfiles-backup
mv ~/.conkyrc ~/.vim ~/.vimperatorrc ~/.vimrc ~/.zsh ~/.zshrc /tmp/dotfiles-backup

cp -r vim ~/
cp -r zsh ~/

cp conkyrc  ~/
cp vimperatorrc ~/
cp vimrc ~/
cp zshrc ~/
