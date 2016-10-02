# @ch3sh1r's dotfiles

![tile](http://dl.dropboxusercontent.com/u/12576522/linked/github-dotfiles/tile.png)

## Установка

ОСТОРОЖНО! Это сотрет всю текущую конфигурацию используемых программ.

### Ubuntu

Старые версии Ubuntu содержат устаревшую версию пакета awesome,
поэтому необходимо добавить
[ppa](https://launchpad.net/~klaus-vormweg/+archive/awesome)
от Klaus Vormweg).

```bash
sudo add-apt-repository ppa:klaus-vormweg/awesome
sudo apt update
sudo apt install vim git zsh grc awesome awesome-extra tmux make
git clone --recurse https://github.com/ch3sh1r/dotfiles ~/.dotfiles
cd ~/.dotfiles
make
```

В терминале используются цвета палитры
[Solarized](http://ethanschoonover.com/solarized).
Для их поддержки в Gnome Terminal нужно установить
[gnome-terminal-colors-solarized](https://github.com/sigurdga/gnome-terminal-colors-solarized)
от [@sigurdga](https://github.com/sigurdga).

Для автокомплита в виме используется плагин
[YouCompleteMe](http://valloric.github.io/YouCompleteMe/)
от [Val Markovic](https://github.com/Valloric).
Он построен по клиент-серверной модели и
требует дополнительных телодвижений при установке и обновлении.

```bash
cd ~/.vim/plugged/YouCompleteMe
./install.py
```

## Зависимости

Настройки понадерганы по всем интернетам, а идея записать что и
откуда пришло возникла не сразу. По этому если вы видите что чего-то в
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
