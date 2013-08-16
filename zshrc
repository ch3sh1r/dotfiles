plugins=(python pip screen)
ZSH_THEME="ch3sh1r"

# .localrc для использования на машине
[[ -f ~/.localrc ]] && . ~/.localrc

# Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# Запуск инициализации
ZSH=$HOME"/.zsh"
source $ZSH/conf.sh
