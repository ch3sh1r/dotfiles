# Переменные среды
PATH="$HOME/.bin:$HOME/.rvm/bin:$HOME/.zsh/script:/usr/local/bin:/usr/local/sbin:/var/lib/gems/bin/:$PATH" && export PATH
MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH" && export MANPATH
EDITOR="vim" && export EDITOR

# Автодополнение к скриптам
fpath=($ZSH/script $fpath)

# Библиотеки
for config_file ($ZSH/lib/*.zsh) source $config_file

# Плагины, запрошенные в ~/.zshrc
plugin=${plugin:=()}
for plugin ($plugins) fpath=($ZSH/plugins/$plugin $fpath)
for plugin ($plugins); do
  if [ -f $ZSH/plugins/$plugin/$plugin.plugin.zsh ]; then
    source $ZSH/plugins/$plugin/$plugin.plugin.zsh
  fi
done

# Инициализация
typeset -U path cdpath fpath manpath
autoload -U compinit 
compinit -i -D

# Показывать меню если есть хотя бы 2 опции
zstyle ':completion:*' menu select=2

