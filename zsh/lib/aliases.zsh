alias iddqd="sudo -s"
alias p="ps auxw"
alias df="df -h"
alias du="du -h"
alias recal="cat ~/.zsh_history|grep"
alias vi="vim"
alias cvi="vim -c :colorscheme\ default"
alias screen="screen -DR"
alias genpasswd='openssl rand -base64 12'

alias ifconfig.me="curl ifconfig.me/all"
alias gist="gist -f"

if [ -f /usr/bin/ack-grep ]; then
    alias grep="/usr/bin/ack-grep"
else
    alias grep="grep --color=auto"
    alias egrep="egrep --color=auto"
    alias fgrep="fgrep --color=auto"
fi

if [ -f /usr/bin/grc ]; then
    alias ping="grc --colour=auto ping"
    alias traceroute="grc --colour=auto traceroute"
    alias make="grc --colour=auto make"
    alias diff="grc --colour=auto diff"
    alias wdiff="grc --colour=auto wdiff"
    alias netstat="grc --colour=auto netstat"
    alias configure="grc --colour=auto configure"
    alias gcc="grc --colour=auto gcc"
    alias last="grc --colour=auto last"
    alias ldap="grc --colour=auto ldap"
    alias mount="grc --colour=auto mount"
    alias mtr="grc --colour=auto mtr"
    alias ps="grc --colour=auto ps"
    alias dig="grc --colour=auto dig"
fi

# Дерево из папки.
alias dirtree='find . -type d | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"' 

# Слепок файлов в директории
alias snap="find $1 -type f | xargs -I{} ls -l {} > snap-`date +%s`"

# Запись скринкаста
alias recdesktop='ffmpeg -f x11grab -s 1920x1080 -r 8 -i :0.0 -sameq '

