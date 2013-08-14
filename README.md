# @ch3sh1r's dotfiles

В целом, все настройки понадерганы из десятков мест по всем 
интернетам. Идея записать что и откуда пришло возникла не сразу.
По этому если вы нашли не хватающее — сообщите мне пожалуйста.

Zsh:

* [@robbyrussell](https://github.com/robbyrussell) — 
  [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh).

Metasploit:
* [@staaldraad](https://github.com/staaldraad) — 
  [metasploit](https://github.com/staaldraad/metasploit).
* [@darkoperator](https://github.com/darkoperator) — 
  [Metasploit-Plugins](https://github.com/darkoperator/Metasploit-Plugins),
  [Meterpreter-Scripts](https://github.com/darkoperator/Meterpreter-Scripts).
* [@mubix](https://github.com/mubix) — 
  [q](https://github.com/mubix/q).
* [@hatsecure](https://github.com/hatsecure/metasploit) — 
  [metasploit](https://github.com/hatsecure).

## Установка

### Установка с Git

Репозиторий клонируется куда угодно (у меня обычно получается 
`~/<long_way_to_code_directory>/dotfiles`) и из него кидаются 
симлинки в `~`:

    git clone https://github.com/ch3sh1r/dotfiles.git && cd dotfiles && ./push.sh -l

Иногда удобнее скопировать минимально необходимое и обойтись 
без зависимостей в виде симлинков. На этот случай `./push.sh -f`
скопирует все без настроек awesome и еще какой-то шелухи.

## Установка без Git

Можно скачать архив со свежайшими комитами:

    cd; wget https://github.com/ch3sh1r/dotfiles/tarball/master

Затем ручками распаковать (`tar xzf dotfiles`) и выполнить `./push.sh`.
