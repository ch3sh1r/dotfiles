" @ch3sh1r vimrc (https://github.com/ch3sh1r/dotfiles)
" Maintained by Alexey Bednyakov, <ch3sh1r@ya.ru>

set nocompatible            " Предпочтение настройкам Vim относительно Vi
set ruler                   " Показывать положение курсора всё время
set showcmd                 " Показывать незавершенные команды в статусбаре
set nu                      " Нумерация строк
set wrap                    " Перенос строк
set linebreak               " Перенос строк по словам, а не по буквам
set foldmethod=indent       " Фолдинг по отступам
set modelines=0             " Во-первых не нужны, во-вторых - дырки (http://clck.ru/Lx2G)
set scrolljump=3            " Теперь нет необходимости передвигать курсор к
set scrolloff=3             "  краю экрана, чтобы подняться/опуститься
set history=128             " Хранить больше истории команд
set undolevels=2048         "  и правок
set nobackup                " Не создавать бэкапы
set bs=2                    " Backspace работает как всегда

call plug#begin('~/.vim/plugged')
    Plug 'junegunn/vim-easy-align'
    Plug 'junegunn/vim-github-dashboard'
    Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
    Plug 'scrooloose/nerdcommenter'
    Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
    Plug 'tpope/vim-fireplace', { 'for': 'clojure' }
    Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
    Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }
call plug#end()

" Выключить звуки
    set noerrorbells
    set novisualbell
    set tm=500
    set t_vb=

" Строка состояния
    set ch=1                " Строка команд высотой в одну строку
    set laststatus=2        " У последнего окна всегда есть статус
    set statusline=\ %<%-15.25(%f%)%m%r%h\ %w
    set statusline+=\ %20.40(%{hostname()}:%{CurDir()}%)
    set statusline+=\ %=%-8.(%l,%c%V%)\ %p%%/%L
    function! CurDir()
        let curdir = substitute(getcwd(), $HOME, "~", "")
            return curdir
    endfunction

" Отступы и табы
    set autoindent
    set expandtab
    set shiftwidth=4
    set softtabstop=4
    set tabstop=4
    set smartindent
    set smarttab

" Поддержка мыши
    set mouse=a             " Использовать мышь, если терминал позволяет
    set mousemodel=popup    " Выдавать меню по правому клику
    set mousehide           " Скрывать указатель мыши во время печати

" Поиск
    set ignorecase          " Поиск не чувствительный к регистру
    set smartcase           "  сообразительный
    set incsearch           "  по набору текста
    set hlsearch            "  с подсветкой

" Подстветка
    syntax enable
    filetype plugin on
    set t_Co=16
    colorscheme solarized
    set cursorline

" Правила оформления Ruby в Metasploit
" https://github.com/rapid7/metasploit-framework/wiki/Style-Tips
    autocmd BufRead,BufNewFile *.rb set shiftwidth=2 tabstop=2 softtabstop=2 textwidth=78

" Русская раскладка и кодировки
    set termencoding=utf-8
    set fileencodings=utf-8,latin1,cp1251
    set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
    imap ё `
    nmap ё `
    vmap ё `

" Замена <leader> на "," со стандартного "\"
    let mapleader = ","

" Убрать мусор из прошлого поиска
    nnoremap <leader><space> :noh<cr>

" Новый таб
    nmap tn :tabnew

" Беглые скачки
    nmap <Space> <PageDown>
    vmap <Space> <PageDown>
    nmap b <PageUp>
    vmap b <PageUp>

" Поиск нормальными регулярками
    nnoremap / /\v
    vnoremap / /\v

" <leader>e. - смена кодировок
    " <leader>ek - koi8
        nmap <leader>ek :e ++enc=koi8-r<cr>
    " <leader>ew - cp1251
        nmap <leader>ew :e ++enc=cp1251<cr>
    " <leader>ec - cp866
        nmap <leader>ec :e ++enc=cp866<cr>
    " <leader>eu - utf8
        nmap <leader>eu :e ++enc=utf8<cr>
    " <leader>er - rot13
        nmap <leader>er ggg?G <cr>
