# Подключаемые плагины
plugins=(
    git
    common-aliases
    extract
    zsh-syntax-highlighting
)

# Имя цветовой темы
ZSH_THEME="kennethreitz"

# Правильное отображение цветов
TERM="xterm-256color"

# .localrc для использования на машине
[[ -f ~/.localrc ]] && . ~/.localrc

# Запуск инициализации
ZSH=$HOME"/.zsh"
source $ZSH/conf.sh
