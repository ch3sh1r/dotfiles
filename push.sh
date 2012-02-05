#!/bin/bash
# Push all files at right places.

function push_files() {
    # Плацдарм
    temp="/tmp/dotfiles-"`date | md5sum | cut -f1 -d' ' | head -c10`
    mkdir $temp
    rsync --exclude ".git/" --exclude ".DS_Store" --exclude "push.sh" --exclude "readme.md" -av . $temp > /dev/null
    for file in `ls $temp`; do
        mv -f $temp"/"$file $temp"/."$file
    done
    rsync -av $temp"/." $HOME > /dev/null
    rm -rf $temp
}

function link_files() {
    for file in `ls`; do
        rm -rf $HOME"/."$file
        ln -s $PWD"/"$file $HOME"/."$file
    done
    rm $HOME"/.push.sh" 
    rm $HOME"/.README.md"
}

cd "$(dirname "$0")"
if [ "$1" == "--force" -o "$1" == "-f" ]; then
    push_files
elif [ "$1" == "--link" -o "$1" == "-l" ]; then
    link_files
else
    read -p "This will overwrite existing files in your home directory. Proceed? (y/n) " -n 1
    git pull
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        push_files
    fi
fi

unset push_files
unset link_files

