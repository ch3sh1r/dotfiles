#!/bin/bash
# Push all files at right places.

cd "$(dirname "$0")"
if [ $1 ] ; then
    case $1 in
        -f) #for server-like shell
            temp="$(mktemp -t ".dfXXXXXXX" -d)"
            rsync --exclude ".*" \
                  --exclude "push.sh" \
                  --exclude "gvimrc" \
                  --exclude "vimperator" \
                  --exclude "vimperatorrc" \
                  --exclude "config" \
                  --exclude "msf4" \
                  --exclude "README.md" \
                  -av . $temp > /dev/null
            for dotfile in `ls $temp`; do
                mv -f $temp"/"$dotfile $temp"/."$dotfile
            done
            rsync -av $temp"/." ${HOME} > /dev/null
            rm -rf $temp
        ;;
        -l) #for workstations (and work groups)
            for dotfile in `ls`
            do
                if [ $dotfile == "push.sh" -o \
                     $dotfile == "README.md" ]; then
                    false

                elif [ $dotfile == "config" ]; then
                    if ! [ -d "${HOME}/.config" ]; then 
                        mkdir "${HOME}/.config" 
                    fi
                    for config in `ls config`; do
                        rm -rf "${HOME}/.config/${config}"
                        ln -s "${PWD}/config/${config}" "${HOME}/.config/${config}"
                    done

                elif [ $dotfile == "msf4" ]; then
                    msftemp="$(mktemp --tmpdir="${HOME}" -t ".msf4XXXXXXX" -d)"
                    for msffile in history local logs loot; do
                        [ -f "${HOME}/.msf4/${msffile}" ] && \
                            mv "${HOME}/.msf4/${msffile}" ${msftemp}; done
                    rm -rf "${HOME}/.msf4"
                    ln -s "${PWD}/msf4" "${HOME}/.$dotfile"
                    for msffile in history local logs loot; do
                        [ -f "${msftemp}/${msffile}" ] && \
                            mv "${msftemp}/${msffile}" "${HOME}/.msf4"; done
                    rm -rf ${msftemp}

                else
                    rm -rf "${HOME}/.${dotfile}"
                    ln -s "${PWD}/$dotfile" "${HOME}/.$dotfile"
                fi
            done
        ;;
    esac
else
    echo "Usage:"
    echo "  push.sh -f  - change existing."
    echo "  push.sh -l  - remove existing and create symlinks."       
fi
