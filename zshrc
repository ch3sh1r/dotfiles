# Подключаемые плагины
plugins=(
    ansible
    brew
    colorize
    common-aliases
    extract
    git
    pip
    vagrant
    zsh-syntax-highlighting
)

# Имя цветовой темы
ZSH_THEME="sunrise"

# Правильное отображение цветов
TERM="xterm-256color"

# Запуск инициализации
export ZSH=$HOME/.zsh
source $ZSH"/oh-my-zsh.sh"

# .localrc для использования на машине
[[ -f ~/.localrc ]] && . ~/.localrc
