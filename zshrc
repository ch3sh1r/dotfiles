# Подключаемые плагины
plugins=(
    git
    common-aliases
    extract
    zsh-syntax-highlighting
)

# Имя цветовой темы
ZSH_THEME="terminalparty"

# Правильное отображение цветов
TERM="xterm-256color"

# .localrc для использования на машине
[[ -f ~/.localrc ]] && . ~/.localrc

# Запуск инициализации
export ZSH=$HOME/.zsh
source $ZSH"/oh-my-zsh.sh"
