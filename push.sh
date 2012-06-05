#!/bin/bash
# Push all files at right places.

function _push_files() {
    temp="/tmp/dotfiles-"`date | md5sum | cut -f1 -d' ' | head -c10`
    mkdir $temp
    rsync --exclude ".git/" \
          --exclude ".DS_Store" \
          --exclude "push.sh" \
          --exclude "config" \
          --exclude "README.markdown" \
          -av . $temp > /dev/null
    for dotfile in `ls $temp`; do
        mv -f $temp"/"$dotfile $temp"/."$dotfile
    done
    rsync -av $temp"/." ${HOME} > /dev/null
    rm -rf $temp
}

function _link_files() {
    for dotfile in `ls`
    do
        if [ $dotfile == "push.sh" -o $dotfile == "README.markdown" ]
        then
            false
        elif [ $dotfile == "config" ]
        then
            for config in `ls config`
            do
                rm -rf ${HOME}"/.config/"$config
                ln -s ${PWD}"/config/"$config ${HOME}"/.config/"$config
            done
        else
            rm -rf ${HOME}"/."$dotfile
            ln -s ${PWD}"/"$dotfile ${HOME}"/."$dotfile
        fi
    done
}

cd "$(dirname "$0")"
if [ "$1" == "--force" -o "$1" == "-f" ]
then
    _push_files
elif [ "$1" == "--link" -o "$1" == "-l" ]
then
    _link_files
else
    read -p "This will overwrite existing files. Proceed? (y/n) " -n 1
    git pull
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        _push_files
    fi
fi

unset _push_files
unset _link_files

