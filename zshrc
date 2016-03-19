# Подключаемые плагины
plugins=(python pip)

# Имя цветовой темы
ZSH_THEME="ch3sh1r"

# Правильное отображение цветов
TERM="xterm-256color"

# .localrc для использования на машине
[[ -f ~/.localrc ]] && . ~/.localrc

# Запуск инициализации
ZSH=$HOME"/.zsh"
source $ZSH/conf.sh
