# Подключаемые плагины
plugins=(
    ansible
    brew
    common-aliases
    docker
    docker-compose
    extract
    git
    grc
    kitchen
    knife
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
