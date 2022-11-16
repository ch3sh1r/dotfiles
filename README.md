# @ch3sh1r's dotfiles

## Установка

*WARNING*! Next steps will remove current configuration files.

*ОСТОРОЖНО*! Это сотрет всю текущую конфигурацию используемых программ.

### Debian based

```bash
sudo apt update
sudo apt install vim git fish tmux make
git clone --recursive https://github.com/ch3sh1r/dotfiles ~/.dotfiles
cd ~/.dotfiles
make
```

В терминале используются цвета палитры
[Solarized](http://ethanschoonover.com/solarized).
Для их поддержки в Gnome Terminal нужно установить
[gnome-terminal-colors-solarized](https://github.com/sigurdga/gnome-terminal-colors-solarized)
от [@sigurdga](https://github.com/sigurdga).

### macOS

```bash
brew install vim git fish tmux make
git clone --recursive https://github.com/ch3sh1r/dotfiles ~/.dotfiles
cd ~/.dotfiles
make
```

