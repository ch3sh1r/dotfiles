#!/bin/bash

DOTFILE="gitconfig tmux.conf gvimrc"
DOTFILE_RC="vim"
DOTFILE_CONFIG="fish i3 i3status"
DOTFILES="$DOTFILE_RC $DOTFILE_CONFIG $DOTFILE"
DOTFILES_PATH=$(dirname $(realpath ${BASH_SOURCE[0]}))

install_packages() {
    sudo apt-get update
    sudo apt-get install -y vim fish git i3
}

all() {
    if [[ $install_flag == "true" ]]; then
        install_packages
    fi

    for dotfile in $DOTFILES; do
        make_link $dotfile
    done
}

make_link() {
    dotfile=$1
    case $dotfile in
        $DOTFILE_RC)
            rm -Rf ~/.$dotfile"rc"
            rm -Rf ~/.$dotfile
            ln -sf $DOTFILES_PATH/$dotfile"rc" ~/.$dotfile"rc"
            ln -sf $DOTFILES_PATH/$dotfile ~/.$dotfile
            ;;
        $DOTFILE_CONFIG)
            mkdir -p ~/.config
            rm -Rf ~/.config/$dotfile
            ln -sf $DOTFILES_PATH/$dotfile ~/.config/$dotfile
            ;;
        *)
            rm -Rf ~/.$dotfile
            ln -sf $DOTFILES_PATH/$dotfile ~/.$dotfile
            ;;
    esac
}

usage() {
    echo "Usage: $0 [-i]"
    echo "Options:"
    echo "  -i   Install required packages (vim, fish, git, i3)"
}

while getopts ":i" opt; do
    case ${opt} in
        i)
            install_flag="true"
            ;;
        \?)
            echo "Invalid option: $OPTARG" 1>&2
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND -1))

all
