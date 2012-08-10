ZSH=$HOME"/.zsh"
plugins=(python pip)
source $ZSH/conf.sh

# .localrc для использования на машине
[[ -f ~/.localrc ]] && . ~/.localrc

