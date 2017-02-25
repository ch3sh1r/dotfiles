set guifont=Hack\ Regular:h12   " Шрифт
set guioptions-=m               " Убрать отображение меню
set guioptions-=T               " Убрать тулбара
set guioptions-=r               " Убрать правый скролбар
set nolist                      " Убрать подсветку нечитаемых символов

" Локальные настройки
if filereadable(expand("~/.gvimrc.local"))
    source ~/.gvimrc.local
endif
