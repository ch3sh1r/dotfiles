# Подключаемые плагины
plugins=(
    common-aliases
    extract
    emacs
    git
    grc
    zsh-syntax-highlighting
)

# Имя цветовой темы
ZSH_THEME="dogenpunk"

# Правильное отображение цветов
TERM="xterm-256color"

# .localrc для использования на машине
[[ -f ~/.localrc ]] && . ~/.localrc

# Запуск инициализации
export ZSH=$HOME/.zsh
source $ZSH"/oh-my-zsh.sh"
