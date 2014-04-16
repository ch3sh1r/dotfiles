# Инициализация
typeset -U path cdpath fpath manpath
autoload -U compinit 
compinit -i -D

# Переменные среды
PATH="$HOME/.gem/ruby/2.0.0/bin:$HOME/.bin:$HOME/.rvm/bin:$HOME/.zsh/bin:/usr/local/bin:/usr/local/sbin:/var/lib/gems/bin/:/usr/local/heroku/bin:$PATH"
MANPATH="/usr/local/man:/usr/local/mysql/man:/usr/local/git/man:$MANPATH"
EDITOR="vim"
export PATH
export EDITOR
export MANPATH

# Автодополнение к скриптам
fpath=($ZSH/bin $fpath)

# Библиотеки
for config_file ($ZSH/lib/*.zsh) source $config_file

# Плагины, запрошенные в ~/.zshrc
is_plugin() {
  local base_dir=$1
  local name=$2
  test -f $base_dir/plugins/$name/$name.plugin.zsh \
    || test -f $base_dir/plugins/$name/_$name
}
# Add all defined plugins to fpath. This must be done
# before running compinit.
for plugin ($plugins); do
  if is_plugin $ZSH_CUSTOM $plugin; then
    fpath=($ZSH_CUSTOM/plugins/$plugin $fpath)
  elif is_plugin $ZSH $plugin; then
    fpath=($ZSH/plugins/$plugin $fpath)
  fi
done
# Load all of the plugins that were defined in ~/.zshrc
for plugin ($plugins); do
  if [ -f $ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh ]; then
    source $ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh
  elif [ -f $ZSH/plugins/$plugin/$plugin.plugin.zsh ]; then
    source $ZSH/plugins/$plugin/$plugin.plugin.zsh
  fi
done

# Загрузка цветовой темы
if [ "$ZSH_THEME" = "random" ]
then
  themes=($ZSH/themes/*zsh-theme)
  N=${#themes[@]}
  ((N=(RANDOM%N)+1))
  RANDOM_THEME=${themes[$N]}
  source "$RANDOM_THEME"
  echo "Random theme '$RANDOM_THEME' loaded"
else
  if [ ! "$ZSH_THEME" = ""  ]
  then
    if [ -f "$ZSH_CUSTOM/$ZSH_THEME.zsh-theme" ]
    then
      source "$ZSH_CUSTOM/$ZSH_THEME.zsh-theme"
    elif [ -f "$ZSH_CUSTOM/themes/$ZSH_THEME.zsh-theme" ]
    then
      source "$ZSH_CUSTOM/themes/$ZSH_THEME.zsh-theme"
    else
      source "$ZSH/themes/$ZSH_THEME.zsh-theme"
    fi
  fi
fi

# Показывать меню если есть хотя бы 2 опции
zstyle ':completion:*' menu select=2
