# Подключаемые плагины
plugins=(
    common-aliases
    extract
    git
    ssh-agent
    zsh-syntax-highlighting
)

# Имя цветовой темы
ZSH_THEME="sunrise"

# Правильное отображение цветов
TERM="xterm-256color"

# .localrc для использования на машине
[[ -f ~/.localrc ]] && . ~/.localrc

# Не спрашивать пароли на ключи на старте
zstyle :omz:plugins:ssh-agent lazy yes

# PIP3 executables
path+=('/home/ch3sh1r/.local/bin')
export PATH

# Запуск инициализации
export ZSH=$HOME/.zsh
source $ZSH"/oh-my-zsh.sh"
