autoload -U compinit		# Загрузка умных автодополнений
compinit -D 				# Вкл. автодополнение c кэшем для ускорения
autoload colors && colors	# Pаскраска через $fg, $bg etc.

#
# Автокомплит.
#

zstyle ':completion:*' menu yes select
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:processes' command 'ps x -o pid,pcpu,tt,args'

# Списки для отделных команд.
compctl -k "( status help puburl stop running start filestatus ls autostart exclude )" dropbox
compctl -k "(  bundle freeze help install search uninstall unzip zip )" pip
compctl -k "( aix arm asp bsd bsdi cgi freebsd generator hardware hp-ux irix jsp lin linux minix multiple netbsd novell openbsd os-x osX php plan9 QNX sco solaris tru64 ultrix unix unixware webapps win32 win64 windows )" searchsploit
compctl -k "( startproject shell crawl )" scrapy


#
# Переменные среды.
#

# Куда писать историю
HISTFILE=~/.zhistory
# Число команд, сохраняемых в истории
SAVEHIST=7000
# Не писать в историю команды, начинающиеся с пробела
setopt HIST_IGNORE_SPACE
# Игнорировать все повторения команд
setopt HIST_IGNORE_ALL_DUPS
# Игнорировать лишние пробелы
setopt HIST_IGNORE_SPACE
# Не пиликать.
setopt NO_BEEP
# Перемещасться в директорию без cd.
setopt AUTO_CD
# Править все, при любой возможности.
setopt CORRECT_ALL
# zsh будет обращаться с пробелами так же, как и bash
setopt SH_WORD_SPLIT 
# Не считать Control+C за выход из оболочки
setopt  IGNORE_EOF


#
# Интеграция с vim.
#

export EDITOR=vim
bindkey -v
# Создание режимов на основе существующих.
bindkey -N myviins viins
bindkey -N myvicmd vicmd
# Отображение действующего режима.
function zle-line-init zle-keymap-select {
    RPS1="${${KEYMAP/vicmd/-- NORMAL --}/(main|viins)/-- INSERT --}"
    RPS2=$RPS1
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
# Памятка с текущими привязками.
function list_mappings(){bindkey}; zle -N list_mappings
alias :map='list_mappings'
# Режим вставки по умолчанию.
bindkey -A myviins main
# Заплатки для непривычного поведения.
bindkey "\e[2~" yank
bindkey "\e[3~" delete-char
bindkey "\e[5~" up-line-or-history
bindkey "\e[6~" down-line-or-history
bindkey "\e[A" up-line-or-search # Верхняя стелка := вверх по истории
bindkey "\e[B" down-line-or-search # Нижняя стелка := вниз по истории


# Автоматическое удаление одинакового из этого массива
typeset -U path cdpath fpath manpath

# Установка приглашения.
PROMPT="%(#.%{$bg[red]%}.%{$fg[green]%})%n%{$reset_color%}%{$fg[lightgrey]%}@%m %~ %{$reset_color%}
%(?.%{$fg[lightgrey]%}.%{$bg[red]%})>>%{$reset_color%} "

# Вопрос на автокоррекцию
SPROMPT='zsh: Change '\''%R'\'' to '\''%r'\''? [y/N/a/e] '

# Экранируем спецсимволы в url (например &, ?, ~)
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

#разукрашиваем ls и grep и автодополнение
export LS_COLORS='no=00;37:fi=00;37:di=01;36:ln=04;36:pi=33:so=01;35:do=01;35:bd=33;01:cd=33;01:or=31;01:su=37:sg=30:tw=30:ow=34:st=37:ex=01;31:*.cmd=01;31:*.exe=01;31:*.com=01;31:*.btm=01;31:*.sh=01;31:*.run=01;31:*.tar=33:*.tgz=33:*.arj=33:*.taz=33:*.lzh=33:*.zip=33:*.z=33:*.Z=33:*.gz=33:*.bz2=33:*.deb=33:*.rpm=33:*.jar=33:*.rar=33:*.jpg=32:*.jpeg=32:*.gif=32:*.bmp=32:*.pbm=32:*.pgm=32:*.ppm=32:*.tga=32:*.xbm=32:*.xpm=32:*.tif=32:*.tiff=32:*.png=32:*.mov=34:*.mpg=34:*.mpeg=34:*.avi=34:*.fli=34:*.flv=34:*.3gp=34:*.mp4=34:*.divx=34:*.gl=32:*.dl=32:*.xcf=32:*.xwd=32:*.flac=35:*.mp3=35:*.mpc=35:*.ogg=35:*.wav=35:*.m3u=35:';
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
export GREP_COLOR="1;33"


# Значение цветов 
#   00 восстановление цвета по умолчанию 
#   01 включить яркие цвета 
#   04 подчеркнутый текст 
#   05 мигающий текст 
#   30 черный текст 
#   40 черный фон
#   31 красный текст 
#   41 красный фон
#   32 зеленый текст 
#   42 зеленый фон
#   33 желтый (или коричневый) текст 
#   43 желтый (или коричневый) фон
#   34 синий текст 
#   44 синий фон
#   35 фиолетовый текст 
#   45 фиолетовый фон
#   36 cyan текст 
#   46 cyan фон
#   37 белый (или серый) текст 
#   47 белый (или серый) фон

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
# Запуск программ по разрешению.
#
autoload -U pick-web-browser
alias -s {html,htm}=pick-web-browser
alias -s {avi,mpeg,mpg,mov,m2v,flv}=vlc
alias -s {ogg,mp3,wav}=amarok
alias -s txt=vim
alias -s py=python
alias -s pl=perl
alias -s rb=ruby
alias -s {ogg,mp3,wav,wma}=mplayer
autoload -U pick-web-browser
alias -s {html,htm}=pick-web-browser
# В иксах
alias -s {png,gif,jpg,jpeg}=feh
alias -s {pdf,djvu}=evince
# Без иксов
[[ -z $DISPLAY ]] && {
	alias -s {odt,doc,sxw,xls,doc,rtf}=catdoc
	alias -s {png,gif,jpg,jpeg}="fbi -a"
	alias -s {pdf,djvu}=evince
}


#
# Aлиасы
#

alias iddqd='sudo -s'
alias apt-get="sudo apt-get"
alias iftop="sudo iftop"
alias wifi="sudo /usr/bin/wifi"

alias ls='ls -FC --color=auto'
alias l='ls'
alias lr='ls -R'
alias li='ls -i'
alias ll='ls -al'
alias la='ls -A'
alias lsd='ls -ld .*'

alias gs='git status '
alias ga='git add '
alias gb='git branch '
alias gc='git commit'
alias gd='git diff'
alias go='git checkout '
alias gh='git hist'
alias gk='gitk --all&'
alias gx='gitx --all'

alias recal='cat ~/.zhistory|grep'
alias df='df -h'
alias du='du -h'
alias vi='vim'
alias cvi='vim -u /home/chesh1r/.vimrc_nox'
alias screen="screen -DR"
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

alias d='pwd'
alias p='ps auxw'
alias h='history 20'
alias c='clear'
alias i='ipython'
alias e='sudo ifconfig eth0 192.168.0.1'
alias s='startx'

alias -g H="| head"
alias -g T="| tail"
alias -g G="| grep"
alias -g E="| egrep"
alias -g L="| less"
alias -g M="| most"
alias -g S="| sort"
alias -g LL="2>&1 | less"
alias -g CA="2>&1 | cat -A"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"
# Конвертим вывод в utf8
alias -g KU="| iconv -c -f koi8r -t utf8"
alias -g CU="| iconv -c -f cp1251 -t utf8"
# И обратно
alias -g UK="| iconv -c -f utf8 -t koi8r"
alias -g UC="| iconv -c -f utf8 -t cp1251"


#
# Xитрожопые алиасы
#

# Ноутбучный режим энергосбережения (1-5).
alias set_etnergy="sudo echo $1 > /proc/sys/vm/laptop_mode"
# Вывод прав циферками.
alias lls="ls -l | sed -e 's/--x/1/g' -e 's/-w-/2/g' -e 's/-wx/3/g' -e 's/r--/4/g'  -e 's/r-x/5/g' -e 's/rw-/6/g' -e 's/rwx/7/g' -e 's/---/0/g'" 
# Дерево из папки.
alias dirtree='find . -type d | sed -e "s/[^-][^\/]*\//  |/g" -e "s/|\([^ ]\)/|-\1/"' 
# Удалить пробелы и комментарии.
alias delspacecomm="sed '/ *#/d; /^ *$/d' $1"
# Рандомный пароль.
alias genpass="head -c8 /dev/urandom | xxd -ps"
# Узнать айпишник.
alias myip="lynx --source http://www.formyip.com/ | grep The | awk {'print $5'} | cut -f5 -d ' '"
# Подключаем и отключаем проектор
alias proj='xrandr --output VGA --mode 800x600 --output LVDS --mode 1024x600'
alias uproj='xrandr --output VGA --off'


#
# Функции.
#

# Перестановка.
rot13() {
	if [ $# = 0 ] ; then
		tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]"
	else
		tr "[a-m][n-z][A-M][N-Z]" "[n-z][a-m][N-Z][A-M]" < $1
	fi
}

# Распаковка архива...
upack() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1;;
            *.tar.gz)    tar xzf $1;;
            *.bz2)       bunzip2 $1;;
            *.rar)       unrar x $1;;
            *.gz)        gunzip $1;;
            *.tar)       tar xf $1;;
            *.tbz2)      tar xjf $1;;
            *.tgz)       tar xzf $1;;
            *.zip)       unzip $1;;
            *.Z)         uncompress $1;;
            *.7z)        7z x $1;;
            *)           echo "Cannot unpack '$1'..." ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
# ... и упаковка.
pack() {
    if [ $1 ] ; then
        case $1 in
            tbz)    tar cjvf $2.tar.bz2 $2;;
            tgz)    tar czvf $2.tar.gz  $2;;
            tar)    tar cpvf $2.tar  $2;;
            bz2)    bzip $2;;
            gz)     gzip -c -9 -n $2 > $2.gz;;
            zip)    zip -r $2.zip $2;;
            7z)     7z a $2.7z $2;;
            *)      echo "'$1' Cannot be packed via pack()";;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# pastebin
pbin(){
        fload(){
                TFILE=`cat $1|sed 's|%|%25|g;s|&|%26|g;s|+|%2b|g;s|;|%3b|g'`
                curl --data "paste_code='$TFILE'" "http://pastebin.com/api_public.php"
                echo
        }
        case $1 in
        
        -h)
                echo "Usage:"
                echo "        pastebin filename 	for paste a file"
                echo "        pastebin 			for edit/paste on fly"       
        ;;
        *)      if [ -n "$1" -a -f "$1" ];then
                        if [ -s "$1" ];then
                                fload $1
                        else
                                echo file $1 is empty
                        fi
                else
                        TEMPFILE=`mktemp -q /tmp/pastebin.XXXXXX`
                        $EDITOR $TEMPFILE
                        if [ -s "$TEMPFILE" ]; then
                                fload $TEMPFILE
                        fi
                        rm ${TEMPFILE}*
                fi
        ;;
    esac
}

# Локальное зеркало сайта.
lmirror(){
    wget -r -l inf -k -p $1
}

#
# Конвертируем всякую дурь
#

mp32utf() { find -iname '*.mp3' -print0 | xargs -0 mid3iconv -eCP1251 --remove-v1 }

mpg2flv() { ffmpeg -i $1 -ar 22050 -ab 32 -f flv -s 320x240 `echo $1 | awk -F . '{print $1}'`.flv }

flv2xvid() { mencoder "$1" -vf scale=320:240  -ovc xvid -xvidencopts bitrate=250:autoaspect -vf pp=lb -oac mp3lame  -lameopts fast:preset=standard -o  "./basename $1.avi" }

flv2divx() { mencoder "$1" --vf scale=320:240  -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=250:mbd=2:v4mv:autoaspect -vf pp=lb -oac mp3lame  -lameopts fast:preset=standard -o  "./basename $1.avi" }

iso2cd() {"cdrecord -s dev=`cdrecord --devices 2>&1 | grep "\(rw\|dev=\)" | awk {'print $2'} | cut -f'2' -d'=' | head -n1` gracetime=1 driveropts=burnfree -dao -overburn -v"}

nrg2iso() {"dd bs=1k if=$1 of=$2 skip=300"}

win2utf() {"iconv -f CP1251 -t UTF-8 $1 > $1"}

