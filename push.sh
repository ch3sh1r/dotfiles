#!/bin/bash
# Push all files at right places.

cd "$(dirname "$0")"
if [ $1 ] ; then
    case $1 in
        -f)
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
        ;;
        -l)
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
        ;;
    esac
else
    echo "Usage:"
    echo "  push.sh -f  - change existing."
    echo "  push.sh -l  - remove existing and create symlinks."       
fi

