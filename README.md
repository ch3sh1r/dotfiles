# @ch3sh1r's dotfiles

Все настройки понадерганы из десятков мест по всем 
интернетам. А идея записать что и откуда пришло возникла не сразу.
По этому если вы видете что чего-то не хватающет в списке — 
сообщите мне пожалуйста.

Zsh:
* [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
  by [@robbyrussell](https://github.com/robbyrussell).

Metasploit:
* [metasploit](https://github.com/staaldraad/metasploit)
  by [@staaldraad](https://github.com/staaldraad).
* [Metasploit-Plugins](https://github.com/darkoperator/Metasploit-Plugins) and
  [Meterpreter-Scripts](https://github.com/darkoperator/Meterpreter-Scripts)
  by [@darkoperator](https://github.com/darkoperator).
* [q](https://github.com/mubix/q)
  by [@mubix](https://github.com/mubix).
* [metasploit](https://github.com/hatsecure)
  by [@hatsecure](https://github.com/hatsecure/metasploit).

Gnome:
* [gnome-terminal-colors-solarized](https://github.com/sigurdga/gnome-terminal-colors-solarized)
  by [@sigurdga](https://github.com/sigurdga).
* [Ambiance Crunchy](http://gnome-look.org/content/show.php?content=151181) gtk theme
  by [frombenny](http://gnome-look.org/usermanager/search.php?username=frombenny)

Awesome WM:
* [powerarrow-dark](https://github.com/esn89/powerarrow-dark)
  by [@esn89](https://github.com/esn89).

## Внешний вид

![floating](http://dl.dropboxusercontent.com/u/12576522/linked/github-dotfiles/floating.png)
![tile](http://dl.dropboxusercontent.com/u/12576522/linked/github-dotfiles/tile.png)

А еще есть [демонстрация](http://ascii.io/a/4852).

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
