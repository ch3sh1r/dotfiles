" @ch3sh1r vimrc (https://github.com/ch3sh1r/dotfiles)
" Maintained by Alexey Bednyakov, <ch3sh1r@ya.ru>

" pathogen (https://github.com/tpope/vim-pathogen)
filetype off
call pathogen#infect()
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()
filetype plugin indent on
syntax on

set nocompatible            " Предпочтение настройкам Vim относительно Vi
set ruler                   " Показывать положение курсора всё время
set showcmd                 " Показывать незавершённые команды в статусбаре
set nu                      " Нумерация строк
set foldmethod=indent       " Фолдинг по отсупам
set modelines=0             " Во-первых не нужны, во-вторых - дырки (http://clck.ru/Lx2G)
set scrolljump=3            " Теперь нет необходимости передвигать курсор к 
set scrolloff=3             "   краю экрана, чтобы подняться/отпуститься
set history=128             " Хранить больше истории команд
set undolevels=2048         "   и правок
set nobackup                " Не создавать бекапы

"--------------------- СРЕДА -----------------------
    " Выключить звук на ошибки 
        set noerrorbells
        set novisualbell            
        set tm=500
        set t_vb=   

    " Строка состояния 
        set ch=1                " Сделать строку команд высотой в одну строку
        set laststatus=2        " У последнего окна всегда есть статус
        set statusline=\ %<%-15.25(%f%)%m%r%h\ %w\ \
        set statusline+=\ \ \ [%{&ff}/%Y]
        set statusline+=\ \ \ %<%20.30(%{hostname()}:%{CurDir()}%)\
        set statusline+=%=%-10.(%l,%c%V%)\ %p%%/%L
        function! CurDir()
            let curdir = substitute(getcwd(), $HOME, "~", "")
                return curdir
        endfunction

    " Отступов и табов 
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

    " Меню выбора кодировки текста 
        set wildmenu
        set wcm=<Tab> 
        menu Encoding.koi8-r :e ++enc=koi8-r<cr>
        menu Encoding.windows-1251 :e ++enc=cp1251<cr>
        menu Encoding.cp866 :e ++enc=cp866<cr>
        menu Encoding.utf-8 :e ++enc=utf8<cr>

    " Русская раскладка и кодировки
        set termencoding=utf-8
        set fileencodings=utf-8,latin1,cp1251
        set langmap=ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz
        imap ё `
        nmap ё `
        vmap ё `


"--------------------- ПЛАГИНЫ ---------------------
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
            " <leader>ek - koi8.
            nmap <leader>ek :e ++enc=koi8-r<cr>
            vmap <leader>ek :e ++enc=koi8-r<cr>
            imap <leader>ek :e ++enc=koi8-r<cr>
            " <leader>ew - cp1251 она же win.
            nmap <leader>ew :e ++enc=cp1251<cr>
            vmap <leader>ew :e ++enc=cp1251<cr>
            imap <leader>ew :e ++enc=cp1251<cr>
            " <leader>ec - cp866.
            nmap <leader>ec :e ++enc=cp866<cr>
            vmap <leader>ec :e ++enc=cp866<cr>
            imap <leader>ec :e ++enc=cp866<cr>
            " <leader>eu - utf8. Yarr!
            nmap <leader>eu :e ++enc=utf8<cr>
            vmap <leader>eu :e ++enc=utf8<cr>
            imap <leader>eu :e ++enc=utf8<cr>
            " <leader>eu - rot13 до конца файла.
            nmap <leader>er g?G <cr>
            vmap <leader>er g?G <cr>
            imap <leader>er g?G <cr>
            
    " F<номер>-шорткаты
        " `+F2 - быстрое сохранение без вопросов
            nmap `<F2> :w!<cr>
            vmap `<F2> <esc>:w!<cr>
            imap `<F2> <esc>:w!<cr>

        " 1+F2 - быстрое sudo-сохранение
            nmap 1<F2> :w !sudo tee %<cr>
            vmap 1<F2> <esc>:w !sudo tee %<cr>
            imap 1<F2> <esc>:w !sudo tee %<cr>

        " F7 - проверка орфографии
            imap <F7> <Esc>:setlocal spell spelllang=ru_yo,en_us<CR>a
            nmap <F7> :setlocal spell spelllang=ru_yo,en_us<CR>

        " Shift-F7 - отключить проверку орфографии
            imap <S-F7> <Esc>:setlocal spell spelllang=<CR>a
            nmap <S-F7> :setlocal spell spelllang=<CR>

    " Работа с буерами
        " Быстрый сплит
        nnoremap <leader>w <C-w>v<C-w>l   
        " Быстрое перемещение
        nnoremap <C-h> <C-w>h
        nnoremap <C-j> <C-w>j
        nnoremap <C-k> <C-w>k
        nnoremap <C-l> <C-w>l

