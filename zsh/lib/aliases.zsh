alias iddqd="sudo -s"
alias p="ps auxw"
alias df="df -h"
alias du="du -h"
alias vi="vim"
alias genpasswd='openssl rand -base64 12'

if [ -f /usr/bin/ack-grep ]; then
    alias grep="/usr/bin/ack-grep"
else
    alias grep="grep --color=auto"
    alias egrep="egrep --color=auto"
    alias fgrep="fgrep --color=auto"
fi

if [ -f $(which grc) ]; then
    alias ping="grc --colour=auto ping"
    alias traceroute="grc --colour=auto traceroute"
    alias diff="grc --colour=auto diff"
    alias wdiff="grc --colour=auto wdiff"
    alias configure="grc --colour=auto configure"
    alias gcc="grc --colour=auto gcc"
    alias last="grc --colour=auto last"
    alias ldap="grc --colour=auto ldap"
    alias mount="grc --colour=auto mount"
    alias mtr="grc --colour=auto mtr"
    alias ps="grc --colour=auto ps"
    alias dig="grc --colour=auto dig"
    alias make="grc --colour=auto make"
fi

# Дерево из папки.
alias dirtree='find . -type d | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"' 

# Запись скринкаста
alias recdesk='ffmpeg -f x11grab -s 1366x768 -r 8 -i :0.0 -qscale 0'
