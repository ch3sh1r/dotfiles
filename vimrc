" @ch3sh1r vimrc (https://github.com/ch3sh1r/dotfiles)
" Maintained by Alexey Bednyakov, <ch3sh1r@ya.ru>

set nocompatible                 " Предпочтение настройкам Vim относительно Vi
set ruler                        " Показывать положение курсора всё время
set showcmd                      " Показывать незавершенные команды в статусбаре
set number                       " Нумерация строк
set relativenumber               " Относительная нумерация строк
set wrap                         " Перенос строк
set linebreak                    " Перенос строк по словам, а не по буквам
set foldmethod=indent            " Фолдинг по отступам
set scrolljump=2                 " Теперь нет необходимости передвигать курсор к
set scrolloff=2                  "  краю экрана, чтобы подняться/опуститься
set backspace=indent,eol,start   " Backspace работает как всегда

call plug#begin('~/.vim/plugged')
    Plug 'altercation/vim-colors-solarized'
    Plug 'scrooloose/nerdcommenter'
    Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
    Plug 'rust-lang/rust.vim'
call plug#end()

" История
    set nobackup                 " Не создавать бэкапы
    set history=128              " Хранить больше истории команд
    set undolevels=2048          " Хранить больше истории правок

" Строка состояния
    set ch=1                     " Строка команд высотой в одну строку
    set laststatus=2             " У последнего окна всегда есть статус

" Отступы и табы
    set smarttab
    set tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab
    autocmd FileType py setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
    autocmd FileType rs setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab

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
    set t_Co=16
    set background=dark
    colorscheme solarized
    set cursorline

" Русская раскладка и кодировки
    set termencoding=utf-8
    set fileencodings=utf-8,latin1,cp1251
    set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
    map ё `

" Замена <leader> на пробел со стандартного "\"
    let mapleader = ' '

" Убрать мусор из прошлого поиска
    nmap <leader><space> :noh<cr>

" Непечатные символы
    let &colorcolumn=join(range(81,81),",")
    set list
    set listchars=eol:¶,tab:→\ ,trail:~,extends:›,precedes:‹,space:·,nbsp:‡
    highlight SpecialKey ctermbg=10 ctermfg=8 term=standout cterm=standout
    highlight NonText    ctermbg=10 ctermfg=8 term=standout cterm=standout
    function! ToggleList()
        if &list
            set nolist
            let &colorcolumn=""
        else
            set list
            let &colorcolumn=join(range(81,81),",")
        endif
    endfunction
    nmap <leader>l :call ToggleList()<cr>

" Поиск регулярками
    nmap / /\v
    vmap / /\v

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
    map <leader>a :bprev<return>
    map <leader>s :bnext<return>
    map <leader>d :bd<return>

" Верхний бар Airline
    let g:airline#extensions#tabline#enabled = 1
