" @ch3sh1r vimrc (https://github.com/ch3sh1r/dotfiles)
" Maintained by Alexey Bednyakov, <ch3sh1r@ya.ru>

set hidden
set nocompatible         " Предпочтение настройкам Vim относительно Vi
set ruler                " Показывать положение курсора всё время
set showcmd              " Показывать незавершенные команды в статусбаре
set nu                   " Нумерация строк
set wrap                 " Перенос строк
set linebreak            " Перенос строк по словам, а не по буквам
set foldmethod=indent    " Фолдинг по отступам
set modelines=0          " Во-первых не нужны, во-вторых - дырки (http://clck.ru/Lx2G)
set scrolljump=2         " Теперь нет необходимости передвигать курсор к
set scrolloff=2          "  краю экрана, чтобы подняться/опуститься
set history=128          " Хранить больше истории команд
set undolevels=2048      " Хранить больше истории правок
set nobackup             " Не создавать бэкапы
set bs=2                 " Backspace работает как всегда

call plug#begin('~/.vim/plugged')
    Plug 'altercation/vim-colors-solarized'
    Plug 'junegunn/vim-easy-align'
    Plug 'scrooloose/nerdcommenter'
    Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
    Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
    Plug 'Valloric/YouCompleteMe' | Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
    Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'
    Plug 'vim-ctrlspace/vim-ctrlspace'
call plug#end()

" Выключить звуки
    set noerrorbells
    set novisualbell
    set tm=500
    set t_vb=

" Строка состояния
    set ch=1             " Строка команд высотой в одну строку
    set laststatus=2     " У последнего окна всегда есть статус

" Скрытие блоков
    set autoindent
    set smartindent

" Отступы и табы
    set smarttab
    set shiftwidth=4
    set softtabstop=4
    set tabstop=4
    set expandtab
    autocmd FileType c,cpp set noexpandtab

" Подсвечивание правой границы
    let &colorcolumn=join(range(121,121),",")
    autocmd FileType python let &colorcolumn=join(range(81,81),",")

" Поддержка мыши
    set mouse=a          " Использовать мышь, если терминал позволяет
    set mousemodel=popup " Выдавать меню по правому клику
    set mousehide        " Скрывать указатель мыши во время печати

" Поиск
    set ignorecase       " Поиск не чувствительный к регистру
    set smartcase        "  сообразительный
    set incsearch        "  по набору текста
    set hlsearch         "  с подсветкой

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
    imap ё `
    nmap ё `
    vmap ё `

" Замена <leader> на "," со стандартного "\"
    let mapleader = ","

" Убрать мусор из прошлого поиска
    nnoremap <leader><space> :noh<cr>

" Непечатаемые символы
    set list
    set listchars=eol:¶,tab:→\ ,trail:~,extends:❯,precedes:❮,space:·
    highlight SpecialKey ctermbg=8
    function! ToggleList()
        if &list
            set nolist
        else
            set list
        endif
    endfunction
    nnoremap <leader>l :call ToggleList()<cr>

" Поиск регулярками
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

" Запуск EasyAlign в интерактивном режиме в visual mode
    xmap ga <Plug>(EasyAlign)
    nmap ga <Plug>(EasyAlign)

" Скрипт для YouCompleteMe
    let g:ycm_global_ycm_extra_conf = "~/.vim/.ycm_extra_conf.py"

" Airline
    let g:airline#extensions#tabline#enabled = 1
