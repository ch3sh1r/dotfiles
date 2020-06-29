" @ch3sh1r vimrc (https://github.com/ch3sh1r/dotfiles)
" Maintained by Alexey Bednyakov, <ch3sh1r@ya.ru>

set nocompatible                 " Предпочтение настройкам Vim относительно Vi
set ruler                        " Показывать положение курсора всё время
set showcmd                      " Показывать незавершенные команды в статусбаре
set number                       " Нумерация строк
set relativenumber               " Относительная нумерация строк
set wrap                         " Перенос строк
set linebreak                    " Перенос строк по словам, а не по буквам
set scrolljump=2                 " Теперь нет необходимости передвигать курсор к
set scrolloff=2                  "  краю экрана, чтобы подняться/опуститься
set backspace=indent,eol,start   " Backspace работает как всегда

call plug#begin('~/.vim/plugged')
    Plug 'altercation/vim-colors-solarized'
    Plug 'dyng/ctrlsf.vim'
    Plug 'scrooloose/nerdcommenter'
    Plug 'scrooloose/nerdtree'
    Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
call plug#end()

" История
    set nobackup                 " Не создавать бэкапы
    set history=128              " Хранить больше истории команд
    set undolevels=2048          " Хранить больше истории правок

" Отступы и табы
    set smarttab
    set tabstop=4 softtabstop=4 shiftwidth=4 expandtab

" Поддержка мыши
    set mouse=a                  " Использовать мышь, если терминал позволяет
    set mousemodel=popup         " Выдавать меню по правому клику
    set mousehide                " Скрывать указатель мыши во время печати

" Поиск
    set ignorecase               " Поиск не чувствительный к регистру
    set smartcase                "  сообразительный
    set incsearch                "  по набору текста
    set hlsearch                 "  с подсветкой

" Подстветка
    syntax enable
    filetype plugin on
    if system("defaults read -g AppleInterfaceStyle") =~ '^Dark'
        set background=dark
    else
        set background=light
    endif
    colorscheme solarized

" Русская раскладка и кодировки
    set termencoding=utf-8
    set fileencodings=utf-8,latin1,cp1251
    set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz

" Замена <leader> на пробел со стандартного "\"
    let mapleader = ' '

" Убрать мусор из прошлого поиска
    nmap <leader><space> :noh<cr>

" Непечатные символы
    set listchars=eol:¶,tab:→\ ,trail:~,extends:›,precedes:‹,space:·,nbsp:‡
    function! ToggleList()
        if &list
            set nolist
            let &colorcolumn=""
        else
            set list
            let &colorcolumn=join(range(121,121),",")
        endif
    endfunction
    nmap <leader>l :call ToggleList()<cr>

" Поиск выделенного
    vmap // y/\c<c-r>"<cr>
    vmap /? y?\c<c-r>"<cr>

" <leader>e. - смена кодировок
    nmap <leader>ek :e ++enc=koi8-r<cr>
    nmap <leader>ew :e ++enc=cp1251<cr>
    nmap <leader>ec :e ++enc=cp866<cr>
    nmap <leader>eu :e ++enc=utf8<cr>
    nmap <leader>er ggg?G <cr>

" Перемещение по буферам
    map <leader>a :bprev!<return>
    map <leader>s :bnext!<return>
    map <leader>d :bd<return>

" Поиск по файлам
    nmap     <C-F>f <Plug>CtrlSFPrompt
    vmap     <C-F>f <Plug>CtrlSFVwordPath
    vmap     <C-F>F <Plug>CtrlSFVwordExec
    nmap     <C-F>n <Plug>CtrlSFCwordPath
    nmap     <C-F>p <Plug>CtrlSFPwordPath
    nnoremap <C-F>o :CtrlSFOpen<CR>
    nnoremap <C-F>t :CtrlSFToggle<CR>
    inoremap <C-F>t <Esc>:CtrlSFToggle<CR>

" Верхний бар Airline
    let g:airline#extensions#tabline#enabled = 1
