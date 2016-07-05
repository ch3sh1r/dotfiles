"Убрать отображение меню
"set guioptions-=m

" Убрать тулбара
set guioptions-=T

" Убрать правый скролбар
set guioptions-=r

" Шрифт
set guifont=Meslo\ LG\ S\ Regular\ for\ Powerline:h12

" Локальные настройки
if filereadable(expand("~/.gvimrc.local"))
    source ~/.gvimrc.local
endif
