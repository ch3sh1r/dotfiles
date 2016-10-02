set guioptions-=m   " Убрать отображение меню
set guioptions-=T   " Убрать тулбара
set guioptions-=r   " Убрать правый скролбар

" Локальные настройки
if filereadable(expand("~/.gvimrc.local"))
    source ~/.gvimrc.local
endif
