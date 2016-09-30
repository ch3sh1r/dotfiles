# GRC colorizes nifty unix tools all over the place

unalias grc 2> /dev/null
GRC=`command -v grc 2> /dev/null`

func colourify () {
    if [ -n "$SDKTARGETSYSROOT" ]; then
        $@
    else
        $GRC -es --colour=auto $@
    fi
}

if [ "$TERM" != dumb ] && [ -n "$GRC" ]; then
    alias configure='colourify configure'
    alias diff='colourify diff'
    alias make='colourify make'
    alias gcc='colourify gcc'
    alias g++='colourify g++'
    alias as='colourify as'
    alias gas='colourify gas'
    alias ld='colourify ld'
    alias netstat='colourify netstat'
    alias ping='colourify ping'
    alias ping6='colourify ping6'
    alias traceroute='colourify traceroute'
    alias dig='colourify dig'
    alias mount='colourify mount'
    alias ps='colourify ps'
    alias mtr='colourify mtr'
    alias df='colourify df -kh'
fi
