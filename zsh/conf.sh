compinit -D 				

# Переменные среды.
PATH="$HOME/bin:$HOME/.bin:/usr/local/homebrew/bin:/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/usr/local/git/bin:/var/lib/gems/bin/:$PATH" && export PATH
MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH" && export MANPATH
MAIL=/var/spool/mail/chesh1r && export MAIL
EDITOR=vim

# Дописываем путь к функциям
fpath=($ZSH/functions $ZSH/completions $fpath)

# Подгружаем все, что похоже оканчивается на .zsh
for config_file ($ZSH/lib/*.zsh) source $config_file

# Дописываем путь к плагинам
plugin=${plugin:=()}
for plugin ($plugins) fpath=($ZSH/plugins/$plugin $fpath)

# Подгружаем плагины, запрошенные в ~/.zshrc
for plugin ($plugins); do
  if [ -f $ZSH/plugins/$plugin/$plugin.plugin.zsh ]; then
    source $ZSH/plugins/$plugin/$plugin.plugin.zsh
  fi
done

# Автоматическое удаление одинакового
typeset -U path cdpath fpath manpath
