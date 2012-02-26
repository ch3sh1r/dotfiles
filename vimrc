
" chesh1r's vimrc
" Maintained by Alexey Bednyakov, <cheshir.box@google.com>

" Загрузка pathogen'a (https://github.com/tpope/vim-pathogen)
filetype off
call pathogen#infect()
call pathogen#helptags()
call pathogen#runtime_append_all_bundles()
filetype plugin indent on
syntax on

set nocompatible            " Предпочтение настройкам Vim относительно Vi
set ruler                   " Показывать положение курсора всё время
set showcmd                 " Показывать незавершённые команды в статусбаре
set nu                      " Включаем нумерацию строк
set autoread                " Автоматическая перезагрузка при изменении
set foldmethod=indent       " Фолдинг по отсупам
set modelines=0             " Во-первых не нужны, во-вторых - дырки (http://clck.ru/Lx2G)
set scrolljump=3            " Теперь нет необходимости передвигать курсор к 
set scrolloff=3             "   краю экрана, чтобы подняться/отпуститься
set shortmess+=I            " И больше не будет детей Уганды
set history=128             " Хранить больше истории команд
set undolevels=2048         "   и правок

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

" Настройка отступов и табов 
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
    set t_Co=256
    let g:solarized_termcolors = 256
    let python_highlight_all = 1
    set background=dark
    colorscheme solarized
    autocmd BufRead *.conf :set filetype=sh

" Меню выбора кодировки текста 
    set wildmenu
    set wcm=<Tab> 
    menu Encoding.koi8-r :e ++enc=koi8-r<cr>
    menu Encoding.windows-1251 :e ++enc=cp1251<cr>
    menu Encoding.cp866 :e ++enc=cp866<cr>
    menu Encoding.utf-8 :e ++enc=utf8<cr>

" Переключение на русскую/английскую раскладку по Ctrl-/ 
    set termencoding=utf-8
    set fileencodings=utf-8,latin1,cp1251
    set keymap=russian-jcukenwin   
    set iminsert=0 
    set imsearch=0 
    cmap  <C-^>
    map   <C-^>X<Esc>:call MyKeyMapHighlight()<CR>a<C-H>
    imap  <Esc>a<C-^><Esc>:call MyKeyMapHighlight()<CR>a
    nmap  a<C-^><Esc>:call MyKeyMapHighlight()<CR>
    vmap  <Esc>a<C-^><Esc>:call MyKeyMapHighlight()<CR>gv
    " Индикация выбранной в данный момент раскладки
    function MyKeyMapHighlight()
       if &iminsert == 0
           hi StatusLine ctermfg=blue guifg=lightblue
       else
           hi StatusLine ctermfg=red guifg=lightred
       endif
    endfunction
    call MyKeyMapHighlight()
    " При изменении активного окна будет выполняться обновление индикации текущей раскладки
    au WinEnter * :call MyKeyMapHighlight()

" Сохранение резервных копий в ~/.backup 
    set backup
    function! BackupDir()
        " определим каталог для сохранения резервной копии
        let l:backupdir=$HOME.'/.backup/'.
                \substitute(expand('%:p:h'), '^'.$HOME, '~', '')
        " если каталог не существует, создадим его рекурсивно
        if !isdirectory(l:backupdir)
            call mkdir(l:backupdir, 'p', 0700)
        endif
        " переопределим каталог для резервных копий
        let &backupdir=l:backupdir
        " переопределим расширение файла резервной копии
        let &backupext=strftime('~%Y-%m-%d~')
    endfunction
    " выполним перед записью буффера на диск
    autocmd! bufwritepre * call BackupDir()

" Автокомплит "из текущего"
    function InsertTabWrapper()
         let col = col('.') - 1
         if !col || getline('.')[col - 1] !~ '\k'
             return "\<tab>"
         else
             return "\<c-p>"
         endif
    endfunction
    " Будем завершать из текущего буфера, других открытых буферов, тегов
    set complete=".bt"

" Cпецифичные для maemo
    " Скроллинг пальцем
    " http://www.vim.org/scripts/script.php?script_id=3141
    "func! MScroll()
      "let l:done=0
      "let l:n = -1
      "let l:w0 = line("w0")
      "let l:last = line("$")
      "while done!=1
        "let l:g = getchar()
        "if l:g != "\<LeftDrag>"
          "let done = 1
        "else
          "if l:n == -1
            "let l:n = v:mouse_lnum
            "let l:fln = v:mouse_lnum
          "else
            "let l:new = l:w0 - v:mouse_lnum + l:n
            "if l:new<1
              "let l:new = 1
            "endif
            "let l:diff = -v:mouse_lnum + l:n
            "let l:nd = line("w$")
            "if l:nd+l:diff>l:last
              "let l:new = l:last - winheight(0) + 1
              "if l:new<1
                "let l:new = 1
              "endif
            "end
            "let l:wn = "normal ".string(l:new)."zt"
            "if (l:n != v:mouse_lnum)
              "exec(l:wn)
              "redraw
            "endif
            "let l:w0 = line("w0")
            "let l:n = v:mouse_lnum + l:diff
          "endif
        "endif
      "endwhile
      ":call cursor(v:mouse_lnum,v:mouse_col)
    "endfunc
    ":set mouse=a
    ":noremap <silent> <LeftMouse> :call MScroll()<CR>
    ":noremap <LeftRelease> <Nop>
    ":noremap <LeftDrag> <Nop>

    " Ctrl-Space (переключение языка) ничего не ломает.
    "imap <Nul> <Nop>
    "map <Nul> <Nop>
    "vmap <Nul> <Nop>
    "cmap <Nul> <Nop>
    "nmap <Nul> <Nop>



"---------------------------------------------------
"--------------------- ПЛАГИНЫ ---------------------
"---------------------------------------------------

" SessionMgr 
    let g:SessionMgr_AutoManage = 0
    let g:SessionMgr_DefaultName = "mysession"

" Tlist (показвать только текущий файл в окне навигации по коду) 
    let g:Tlist_Show_One_File = 1
    set completeopt-=preview
    set completeopt+=longest
    set mps-=[:]
    "map \T :TlistToggle<cr>

" OmniComletion 
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType java set omnifunc=javacomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd FileType css set omnifunc=csscomplete#CompleteCSS
    autocmd FileType c set omnifunc=ccomplete#Complete

" Tasklist 
    map \T :TaskList<cr>

" Самопальные шаблоны
    autocmd! BufNewFile * silent! 0r ~/.vim/templates/template.%:e


"---------------------------------------------------
"--------------------- ХОТКЕИ ----------------------
"---------------------------------------------------

" Ctrl+j - сниппеты
let g:snippetsEmu_key = "<C-j>"

" Shift+Tab - автокомплит "из текущего"
inoremap <silent><S-Tab> <C-r>=InsertTabWrapper()<cr>

" Поиск и замена слова под курсором
nmap ; :%s/\<<c-r>=expand("<cword>")<cr>\>/

" Убрать мусор из прошлого поиска
nnoremap <leader><space> :noh<cr>

" Новый таб
nmap tn :tabnew 

" Беглые скачки
    nmap <Space> <PageDown>
    nmap b <PageUp>

" Поиск нормальными регулярками
    nnoremap / /\v
    vnoremap / /\v
    
" leader-шорткаты
    " \r - запуск Python скриптов
    let g:pymode_run_key = '<leader>r'
    let g:pymode_doc = '<leader>l'

    " \r - для C
    autocmd BufRead *.c nnoremap <leader>r :!tcc -run %<cr>

    " \r. - для LaTeX
    autocmd BufRead *.tex nnoremap <leader>rr :!latex %<cr>
    autocmd BufRead *.tex nnoremap <leader>rp :!pdflatex %<cr>

    " \br - поиск и замена слова под курсором во всех буферах (Tip #382)
        nmap <leader>br :call Replace()<cr>
        fun! Replace()
            let s:word = input("Replace " . expand('<cword>') . " with:")
            :exe 'bufdo! %s/\<' . expand('<cword>') . '\>/' . s:word . '/ge'
            :unlet! s:word
        endfun 

    " \e. - смена кодировок 
        " \ek - koi8.
        nmap <leader>ek :e ++enc=koi8-r<cr>
        vmap <leader>ek :e ++enc=koi8-r<cr>
        imap <leader>ek :e ++enc=koi8-r<cr>
        " \ew - cp1251 она же win.
        nmap <leader>ew :e ++enc=cp1251<cr>
        vmap <leader>ew :e ++enc=cp1251<cr>
        imap <leader>ew :e ++enc=cp1251<cr>
        " \ec - cp866.
        nmap <leader>ec :e ++enc=cp866<cr>
        vmap <leader>ec :e ++enc=cp866<cr>
        imap <leader>ec :e ++enc=cp866<cr>
        " \eu - utf8. Yarr!
        nmap <leader>eu :e ++enc=utf8<cr>
        vmap <leader>eu :e ++enc=utf8<cr>
        imap <leader>eu :e ++enc=utf8<cr>
        " \eu - rot13 до конца файла.
        nmap <leader>er g?G <cr>
        vmap <leader>er g?G <cr>
        imap <leader>er g?G <cr>
        
" F<номер>-шорткаты
    " F1 - больше не поможет
        inoremap <F1> <ESC>
        nnoremap <F1> <ESC>
        vnoremap <F1> <ESC>

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

