# @ch3sh1r's dotfiles

![floating](http://dl.dropboxusercontent.com/u/12576522/linked/github-dotfiles/floating.png)
![tile](http://dl.dropboxusercontent.com/u/12576522/linked/github-dotfiles/tile.png)

## Установка

### Установка с Git
Репозиторий клонируется куда угодно (у меня обычно получается 
`~/<long_way_to_code_directory>/dotfiles`) и из него кидаются 
симлинки в `~`:

    git clone https://github.com/ch3sh1r/dotfiles.git 
    cd dotfiles
    ./push

Иногда удобнее скопировать минимально необходимое и обойтись 
без зависимостей в виде симлинков. На этот случай есть ветка 
[server](https://github.com/ch3sh1r/dotfiles/tree/server).

    git clone https://github.com/ch3sh1r/dotfiles.git 
    cd dotfiles
    git checkout server
    ./push

### Установка без Git
Можно скачать архив текущей версии:

    cd; wget https://github.com/ch3sh1r/dotfiles/tarball/master

Затем ручками распаковать (`tar xzf dotfiles`) и выполнить `./push`.

## Зависимости
Все работает на Ubuntu (с [ppa](https://launchpad.net/~klaus-vormweg/+archive/awesome) от Klaus Vormweg) и ArchLinux.

Настройки понадерганы по всем интернетам, а идея записать что и 
откуда пришло возникла не сразу. По этому если вы видете что чего-то в
списке не хватает — сообщите мне пожалуйста.

Конфигурация zsh основана на 
[oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
от [@robbyrussell](https://github.com/robbyrussell).

Дополнительные модули для metasploit:
* [metasploit](https://github.com/staaldraad/metasploit)
  от [@staaldraad](https://github.com/staaldraad).
* [Metasploit-Plugins](https://github.com/darkoperator/Metasploit-Plugins)
  и [Meterpreter-Scripts](https://github.com/darkoperator/Meterpreter-Scripts)
  от [@darkoperator](https://github.com/darkoperator).
* [q](https://github.com/mubix/q)
  от [@mubix](https://github.com/mubix).
* [metasploit](https://github.com/hatsecure)
  от [@hatsecure](https://github.com/hatsecure/metasploit).

Gnome:
* Тема GTK [Numix](http://numixproject.org/).
* Цвета для gnome-terminal
  [gnome-terminal-colors-solarized](https://github.com/sigurdga/gnome-terminal-colors-solarized)
  от [@sigurdga](https://github.com/sigurdga).
