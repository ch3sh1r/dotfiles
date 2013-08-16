ZSH=$HOME"/.zsh"

plugins=(python pip screen)
ZSH_THEME="random"

# .localrc для использования на машине
[[ -f ~/.localrc ]] && . ~/.localrc

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

source $ZSH/conf.sh
