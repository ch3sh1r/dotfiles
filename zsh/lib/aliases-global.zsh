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

