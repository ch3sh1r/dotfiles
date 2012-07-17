compinit -D 				

# Переменные среды.
PATH="$HOME/.bin:$HOME/.rvm/bin:$ZSH/script:/usr/local/bin:/usr/local/sbin:/var/lib/gems/bin/:$PATH" && export PATH
MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH" && export MANPATH
EDITOR=vim

# Дописываем путь к функциям
fpath=($ZSH/functions $fpath)

# Подгружаем все, что похоже оканчивается на .zsh
for config_file ($ZSH/lib/*.zsh) source $config_file

# Подгружаем плагины, запрошенные в ~/.zshrc
plugin=${plugin:=()}
for plugin ($plugins) fpath=($ZSH/plugins/$plugin $fpath)
for plugin ($plugins); do
  if [ -f $ZSH/plugins/$plugin/$plugin.plugin.zsh ]; then
    source $ZSH/plugins/$plugin/$plugin.plugin.zsh
  fi
done

# Автоматическое удаление одинакового
typeset -U path cdpath fpath manpath

