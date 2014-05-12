# Подключаемые плагины
plugins=()

# Имя цветовой темы
ZSH_THEME="random"

# .localrc для использования на машине
[[ -f ~/.localrc ]] && . ~/.localrc

# Запуск инициализации
ZSH=$HOME"/.zsh"
source $ZSH/conf.sh
