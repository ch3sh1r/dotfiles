alias genpasswd='openssl rand -base64 12'
alias iddqd='sudo -s'
alias l='ls'
alias p='ps auxw'
alias vi='vim'

psgrep() { ps up $(pgrep -f $@) 2>&-; }

alias -g D=' | colordiff | less'
alias -g C=' | column -t'
