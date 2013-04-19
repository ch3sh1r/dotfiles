" @ch3sh1r vimrc (https://github.com/ch3sh1r/dotfiles)
" Maintained by Alexey Bednyakov, <ch3sh1r@ya.ru>

" Vundle (https://github.com/gmarik/vundle)
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
    Bundle 'gmarik/vundle'
    Bundle 'tpope/vim-fugitive'
    Bundle 'scrooloose/nerdcommenter'
    Bundle 'davidhalter/jedi-vim'
    Bundle 'altercation/vim-colors-solarized'
    Bundle 'terryma/vim-multiple-cursors'
    Bundle 'mileszs/ack.vim'
    Bundle 'vim-scripts/TaskList.vim'
    Bundle 'vim-scripts/Conque-Shell'
filetype plugin indent on

set nocompatible            " Предпочтение настройкам Vim относительно Vi
set ruler                   " Показывать положение курсора всё время
set showcmd                 " Показывать незавершенные команды в статусбаре
set nu                      " Нумерация строк
set syntax=on               " Подсветка всегда включена
set foldmethod=indent       " Фолдинг по отступам
set modelines=0             " Во-первых не нужны, во-вторых - дырки (http://clck.ru/Lx2G)
set scrolljump=3            " Теперь нет необходимости передвигать курсор к 
set scrolloff=3             "   краю экрана, чтобы подняться/опуститься
set history=128             " Хранить больше истории команд
set undolevels=2048         "   и правок
set nobackup                " Не создавать бэкапы

"--------------------- СРЕДА -----------------------
    " Выключить звуки
        set noerrorbells
        set novisualbell            
        set tm=500
        set t_vb=   

    " Строка состояния 
        set ch=1                " Строка команд высотой в одну строку
        set laststatus=2        " У последнего окна всегда есть статус
        set statusline=\ %<%-15.25(%f%)%m%r%h\ %w
        set statusline+=\ [%{&ff}/%Y]
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
        set mousehide           " Скрывать указатель мыши когда печатаем

    " Поиск 
        set ignorecase          " Поиск не чувствительный к регистру 
        set smartcase           "   сообразительный 
        set incsearch           "   с подсветкой
        set hlsearch            "   по набору текста

    " Подстветка
        set t_Co=16
        set background=dark
        colorscheme solarized
        autocmd BufRead *.conf :set filetype=sh
        set cursorline

    " Русская раскладка и кодировки
        set termencoding=utf-8
        set fileencodings=utf-8,latin1,cp1251
        set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
        imap ё `
        nmap ё `
        vmap ё `

    " Самопальные шаблоны
        autocmd! BufNewFile * silent! 0r ~/.vim/templates/template.%:e


"--------------------- ХОТКЕИ ----------------------
    " Замена <leader> на "," со стандартного "\"
        let mapleader = ","

    " Поиск и замена слова под курсором
        nmap ; :%s/\<<c-r>=expand("<cword>")<cr>\>/

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

    " leader-шорткаты
        " <leader>e. - смена кодировок 
            " <leader>ek - koi8
                nmap <leader>ek :e ++enc=koi8-r<cr>
            " <leader>ew - cp1251
                nmap <leader>ew :e ++enc=cp1251<cr>
            " <leader>ec - cp866
                nmap <leader>ec :e ++enc=cp866<cr>
            " <leader>eu - utf8
                nmap <leader>eu :e ++enc=utf8<cr>
            " <leader>eu - rot13
                nmap <leader>er ggg?G <cr>

        " <leader>g. - Fugitive
            " <leader>gc - commit
                nmap <leader>gc :Gcommit<cr>
            " <leader>gh - add сохраненные изменения в текущем файле
                nmap <leader>ga :Git add %<cr><cr>
            " <leader>gh - hist (модификация log)
                nmap <leader>gh :Git hist<cr>
            " <leader>gd - diff
                nmap <leader>gd :Gvdiff<cr><C-w>w
            
    " F<номер>-шорткаты
        " `+F2 - быстрое сохранение без вопросов
            nmap `<F2> :w!<cr>
            vmap `<F2> <esc>:w!<cr>
            imap `<F2> <esc>:w!<cr>

        " 1+F2 - быстрое sudo-сохранение
            nmap 1<F2> :w !sudo tee %<cr>
            vmap 1<F2> <esc>:w !sudo tee %<cr>
            imap 1<F2> <esc>:w !sudo tee %<cr>

        " F7 - проверка русской и английской орфографии
            let g:orthography = 0
            function! OrthographyToggle()
              if g:orthography == 0
                let g:orthography = 1
                setlocal spell spelllang=ru_yo,en_us
                echo "Orthography checker toggled on."
              elseif g:orthography == 1
                let g:orthography = 0
                setlocal spell spelllang=
                echo "Orthography checker toggled off."
              endif
            endfunction
            map <F7> :call OrthographyToggle()<cr>

    " Работа с буерами
        " Быстрое перемещение
            nnoremap <C-h> <C-w>h
            nnoremap <C-j> <C-w>j
            nnoremap <C-k> <C-w>k
            nnoremap <C-l> <C-w>l

