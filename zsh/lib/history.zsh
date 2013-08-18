# Куда писать историю
if [ -z $HISTFILE ]; then
    HISTFILE=$HOME/.zsh_history
fi

# Число команд, сохраняемых в истории
HISTSIZE=10000
SAVEHIST=10000

# Не писать в историю команды, начинающиеся с пробела
setopt hist_ignore_space

# Игнорировать повторения команд
setopt hist_ignore_dups
setopt hist_expire_dups_first

setopt append_history
setopt extended_history
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history
