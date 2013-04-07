#
# Простенькая часть
#

alias iddqd="sudo -s"
alias apt-get="sudo apt-get"
alias service="sudo /usr/sbin/service"

alias p="ps auxw"
alias df="df -h"
alias du="du -h"
alias recal="cat ~/.zhistory|grep"
alias vi="vim"
alias cvi="vim -c :colorscheme\ default"
alias screen="screen -DR"

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
  alias netstat="grc --colour=auto netstat"
fi

# Дерево из папки.
alias dirtree='find . -type d | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"' 

# Слепок файлов в директории
alias snap="find $1 -type f | xargs -I{} ls -l {} > snap-`date +%s`"

# Запись скринкаста
alias recdesktop='ffmpeg -f x11grab -s 1920x1080 -r 8 -i :0.0 -sameq '

