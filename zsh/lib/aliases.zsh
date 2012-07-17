#
# Простенькая часть
#

alias _='sudo'
alias iddqd='sudo -s'
alias apt-get="sudo apt-get"
alias iftop="sudo iftop"
alias service="sudo /usr/sbin/service"

alias ls='ls -FC --color=auto'
alias l='ls'
alias lr='ls -R'
alias li='ls -i'
alias ll='ls -al'
alias la='ls -A'
alias lsd='ls -ld .*'

alias gs='git status'
alias ga='git add -A .'
alias gb='git branch'
alias gd='git diff'
alias go='git checkout'
alias gp='git push --all'
alias gk='gitk --all&'
alias gh='git hist' # Для log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short

alias p='ps auxw'
alias df='df -h'
alias recal='cat ~/.zhistory|grep'
alias df='df -h'
alias du='du -h'
alias vi='vim'
alias cvi='vim -c :colorscheme\ default'
alias screen="screen -DR"

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias ifconfig.me='curl ifconfig.me/all'
alias myip='curl ifconfig.me/ip'
alias gist='gist -f'
alias proxylan='export http_proxy="http://proxy.lan:3128" https_proxy="https://proxy.lan:3128"'

# Разукрашиваем некоторые команды с помощью grc
[[ -f /usr/bin/grc ]] && {
  alias ping="grc --colour=auto ping"
  alias traceroute="grc --colour=auto traceroute"
  alias make="grc --colour=auto make"
  alias diff="grc --colour=auto diff"
  alias cvs="grc --colour=auto cvs"
  alias netstat="grc --colour=auto netstat"
}


#
# Xитрожопые алиасы
#

# Палевный семпл nmap (и ооочень тормозной):
# O       - определение ОС, сканирование с применением всех скриптов и трассировки
# sS      - посылать только syn и засчитывать порт открытым при получении syn-ack
# p-      - сканировать порты до 65k, а не стандартные 1024
# PS80,22 - онлайн/оффлайн на основе icmp-echo, а не по доступности tcp порта
# n       - не делать DNS резолв (считывание PTR записей и т.п.)
# T4      - тайминги маленькие, скорость большая
# vvv     - максимальная подробность
# reason  - причина выбора open/closed/filterer/unfiltered
alias nmp="sudo nmap -A -sS -p- -PS80,22 -n -T4 -vvv --reason"

# Режим энергосбережения (1-5).
alias set_etnergy="sudo echo $1 > /proc/sys/vm/laptop_mode"

# Вывод прав циферками.
alias lls="ls -l | sed -e 's/--x/1/g' -e 's/-w-/2/g' -e 's/-wx/3/g' -e 's/r--/4/g'  -e 's/r-x/5/g' -e 's/rw-/6/g' -e 's/rwx/7/g' -e 's/---/0/g'" 

# Дерево из папки.
alias dirtree='find . -type d | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"' 

# Рандомный пароль.
alias genpass="head -c8 /dev/urandom | xxd -ps"

# Подключаем и отключаем проектор
alias proj='xrandr --output VGA --mode 800x600 --output LVDS --mode 1024x600'
alias uproj='xrandr --output VGA --off'

