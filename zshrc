# Путь к корневому каталогу
ZSH=$HOME"/.zsh"

# Конфигурация (списанная с https://github.com/robbyrussell/oh-my-zsh)
plugins=(git python pip)
source $ZSH/conf.sh

# Использовать .localrc для использования на машине
[[ -f ~/.localrc ]] && . ~/.localrc

