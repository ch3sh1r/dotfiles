# Подключаемые плагины
plugins=(python pip archlinux taskwarrior)

# Имя цветовой темы
ZSH_THEME="ch3sh1r"

# .localrc для использования на машине
[[ -f ~/.localrc ]] && . ~/.localrc

# Запуск инициализации
ZSH=$HOME"/.zsh"
source $ZSH/conf.sh
