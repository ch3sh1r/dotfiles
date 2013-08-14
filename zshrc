ZSH=$HOME"/.zsh"
plugins=(python pip screen)
source $ZSH/conf.sh

# .localrc для использования на машине
[[ -f ~/.localrc ]] && . ~/.localrc


### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
