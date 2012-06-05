# Путь к корневому каталогу
ZSH=$HOME"/.zsh"

# Конфигурация (списанная с https://github.com/robbyrussell/oh-my-zsh)
plugins=(python pip)
source $ZSH/conf.sh

# Использовать .localrc для использования на машине
[[ -f ~/.localrc ]] && . ~/.localrc


PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
