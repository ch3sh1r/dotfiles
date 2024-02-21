#!/bin/bash

DOTFILE="gitconfig tmux.conf gvimrc"
DOTFILE_RC="vim"
DOTFILE_CONFIG="fish i3 i3status"
DOTFILES="$DOTFILE_RC $DOTFILE_CONFIG $DOTFILE"
DOTFILES_PATH=$(dirname $(realpath ${BASH_SOURCE[0]}))


prompt_remove_config() {
    read -p "Remove existing dotfiles? (y/N): " choice
    case "$choice" in
        y|Y )
            return 0
            ;;
        * )
            echo "Setup canceled."
            exit 1
            ;;
    esac
}


install_packages() {
    sudo apt-get update
    sudo apt-get install -y vim fish git i3
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
    echo "  -i   Install required packages"
    echo "  -f   Skip confirmation prompt to remove existing configuration"
}


while getopts ":if" opt; do
    case ${opt} in
        f)
            force_flag="true"
            ;;
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

if [[ $install_flag == "true" ]]; then
    install_packages
fi

if [[ $force_flag != "true" ]]; then
    prompt_remove_config
fi

for dotfile in $DOTFILES; do
    echo "Creating symlink for $dotfile."
    make_link $dotfile
done

